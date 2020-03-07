defmodule SprinklerPi.PumpControl do
  @moduledoc """
  control water pump, valve, pump-active-led & check water-sensor
  will broadcast pump on/off & low on water error on topic "pump-control"
  # Broadcast Example on/off
  def handle_info({"pump-change", true, timestamp}, state)
  # Broadcast Example error
  def handle_info({"pump-error", {:error, "water-low"}, timestamp}, state)
  """
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: SprinklerPi.PumpControl)
  end

  @impl true
  def init(_) do
    Phoenix.PubSub.subscribe(SprinklerPiUi.PubSub, "io-change")
    {:ok, {0}}
  end

  @doc """
  get pump state
  # Example
  iex> SprinklerPi.PumpControl.active?()
  ... false
  """
  def active?() do
    SprinklerPi.Control.get_state(:io_motor) == "on"
  end

  @doc """
  get pump error
  # Example
  iex> SprinklerPi.PumpControl.error()
  ... {:ok, nil}
  ... {:error, "water-low"}
  """
  def error() do
    if SprinklerPi.Control.get_state(:io_water_sensor) == "off" do
      {:error, "water-low"}
    else
      {:ok, nil}
    end
  end

  @doc """
  deactivate pump
  # Example
  iex> SprinklerPi.PumpControl.off()
  ... :ok
  """
  def off() do
    Logger.info("SprinklerPi.PumpControl.off")
    SprinklerPi.Control.set_state(:io_motor, "off")
    SprinklerPi.Control.set_state(:io_valve, "off")
    SprinklerPi.Control.set_state(:io_led_green, "off")
  end

  @doc """
  activate pump
  # Example
  iex> SprinklerPi.PumpControl.on()
  ... :ok
  """
  def on() do
    if SprinklerPi.Control.get_state(:io_water_sensor) == "off" do
      Logger.warn("SprinklerPi.PumpControl.on - abort, water low")
      SprinklerPi.Control.set_state(:io_led_red, "on")
      :error
    else
      Logger.info("SprinklerPi.PumpControl.on")
      SprinklerPi.Control.set_state(:io_motor, "on")
      SprinklerPi.Control.set_state(:io_valve, "on")
      SprinklerPi.Control.set_state(:io_led_green, "on")
      SprinklerPi.Control.set_state(:io_led_red, "off")
      :ok
    end
  end

  @impl true
  def handle_info({"io_change", :io_water_sensor, water_state, timestamp}, state) do
    if water_state == "off" do
      Logger.warn("SprinklerPi.PumpControl:io_change - water low, power off pump")
      off()
      SprinklerPi.Control.set_state(:io_led_red, "on")

      Phoenix.PubSub.broadcast(
        SprinklerPiUi.PubSub,
        "pump-control",
        {"pump-error", {:error, "water-low"}, timestamp}
      )
    else
      SprinklerPi.Control.set_state(:io_led_red, "off")

      Phoenix.PubSub.broadcast(
        SprinklerPiUi.PubSub,
        "pump-control",
        {"pump-error", {:ok, nil}, timestamp}
      )
    end

    {:noreply, state}
  end

  @impl true
  def handle_info({"io_change", :io_motor, motor_state, timestamp}, state) do
    Phoenix.PubSub.broadcast(
      SprinklerPiUi.PubSub,
      "pump-control",
      {"pump-change", motor_state == "on", timestamp}
    )

    {:noreply, state}
  end

  def handle_info({"io_change", :io_button, "on", timestamp}, _state) do
    {:noreply, {timestamp}}
  end

  def handle_info({"io_change", :io_button, "off", timestamp}, {last_btn_down})
      when timestamp - last_btn_down > 100_000 do
    {override_active, _} = SprinklerPi.Schedule.get_override()
    if override_active do
      Logger.info("SprinklerPi.PumpControl:io_change - manual off")
      SprinklerPi.Schedule.set_override(false)
    else
      Logger.info("SprinklerPi.PumpControl:io_change - manual on")
      SprinklerPi.Schedule.set_override(true)
    end

    {:noreply, {last_btn_down}}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
