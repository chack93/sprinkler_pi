defmodule SprinklerPi.ControlTarget do
  @moduledoc """
  control hardware peripherals based on gpio pin config in SprinklerPi.Control.
  will broadcast gpio changes over Phoenix.PubSub topic "io-change"
  # Broadcast Example
  def handle_info({"io-change", :io_motor, "on", timestamp}, socket)
  """

  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: SprinklerPi.Control)
  end

  @impl true
  def init(_) do
    {pin_motor, direction, default_motor} = Application.get_env(:sprinkler_pi, :io_motor)
    {:ok, ref_motor} = Circuits.GPIO.open(pin_motor, direction)
    {pin_valve, direction, default_valve} = Application.get_env(:sprinkler_pi, :io_valve)
    {:ok, ref_valve} = Circuits.GPIO.open(pin_valve, direction)
    {pin_led_red, direction, default_led_red} = Application.get_env(:sprinkler_pi, :io_led_red)
    {:ok, ref_led_red} = Circuits.GPIO.open(pin_led_red, direction)

    {pin_led_green, direction, default_led_green} =
      Application.get_env(:sprinkler_pi, :io_led_green)

    {:ok, ref_led_green} = Circuits.GPIO.open(pin_led_green, direction)
    {pin_button, direction, _} = Application.get_env(:sprinkler_pi, :io_button)
    {:ok, ref_button} = Circuits.GPIO.open(pin_button, direction)
    {pin_water_sensor, direction, _} = Application.get_env(:sprinkler_pi, :io_water_sensor)
    {:ok, ref_water_sensor} = Circuits.GPIO.open(pin_water_sensor, direction)

    Circuits.GPIO.set_interrupts(ref_motor, :both)
    Circuits.GPIO.set_interrupts(ref_valve, :both)
    Circuits.GPIO.set_interrupts(ref_led_red, :both)
    Circuits.GPIO.set_interrupts(ref_led_green, :both)
    Circuits.GPIO.set_interrupts(ref_button, :both)
    Circuits.GPIO.set_interrupts(ref_water_sensor, :both)

    Circuits.GPIO.set_pull_mode(ref_motor, :none)
    Circuits.GPIO.set_pull_mode(ref_valve, :none)
    Circuits.GPIO.set_pull_mode(ref_led_red, :none)
    Circuits.GPIO.set_pull_mode(ref_led_green, :none)
    Circuits.GPIO.set_pull_mode(ref_button, :none)
    Circuits.GPIO.set_pull_mode(ref_water_sensor, :none)

    Circuits.GPIO.write(ref_motor, default_motor)
    Circuits.GPIO.write(ref_valve, default_valve)
    Circuits.GPIO.write(ref_led_red, default_led_red)
    Circuits.GPIO.write(ref_led_green, default_led_green)

    {:ok,
     {
       [
         io_motor: ref_motor,
         io_valve: ref_valve,
         io_led_red: ref_led_red,
         io_led_green: ref_led_green,
         io_button: ref_button,
         io_water_sensor: ref_water_sensor
       ],
       %{
         pin_motor => :io_motor,
         pin_valve => :io_valve,
         pin_led_red => :io_led_red,
         pin_led_green => :io_led_green,
         pin_button => :io_button,
         pin_water_sensor => :io_water_sensor
       }
     }}
  end

  @impl true
  @doc """
  turn gpio on or off.
  # Example
  iex> GenServer.cast(SprinklerPi.Control, {:set_state, :io_led_red, "off"})
  ... :ok
  """
  def handle_cast({:set_state, gpio, state}, {ref, pinmap}) do
    gpio_ref = ref[gpio]
    state_int = if state == "on", do: 1, else: 0
    Circuits.GPIO.write(gpio_ref, state_int)
    {:noreply, {ref, pinmap}}
  end

  @impl true
  def handle_info({:circuits_gpio, pin, _timestamp, state}, {ref, pinmap}) do
    timestamp = DateTime.to_unix(DateTime.utc_now(), :microsecond)
    Logger.info("SprinklerPi.Control:circuits_gpio - gpio-event pin/state/ts #{pin}/#{state}/#{timestamp}")

    nice_state = if state == 1, do: "on", else: "off"

    Phoenix.PubSub.broadcast(
      SprinklerPiUi.PubSub,
      "io-change",
      {"io_change", pinmap[pin], nice_state, timestamp}
    )

    {:noreply, {ref, pinmap}}
  end

  @impl true
  @doc """
  read current gpio state. result can be either "off" or "on"
  # Example
  iex> GenServer.call(SprinklerPi.Control, {:get_state, :io_led_red})
  ... "off"
  """
  def handle_call({:get_state, gpio}, _from, {ref, pinmap}) do
    gpio_ref = ref[gpio]
    state = Circuits.GPIO.read(gpio_ref)
    nice_state = if state == 1, do: "on", else: "off"
    {:reply, nice_state, {ref, pinmap}}
  end
end
