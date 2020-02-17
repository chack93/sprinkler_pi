defmodule SprinklerPi.Control do
  @moduledoc """
  control hardware peripherals based on gpio pin config in SprinklerPi.Control.
  will send messages to subscribers whenever gpio state changes.
  """

  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
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
     {[],
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
      }}}
  end

  @impl true
  @doc """
  add given pid to gpio-changes subscribers.
  gpio-changes message example: (gpio, state, timestamp)
  * GenServer.cast(pid, {:io_motor, "on", 123456})
  * GenServer.cast(pid, {:io_button, "off", 123567}
  """
  def handle_cast({:add_subscriber, pid}, {sub_list, ref, pinmap}) do
    {:noreply, {[sub_list | pid]}, ref, pinmap}
  end

  @impl true
  @doc """
  remove given pid from gpio-changes subscribers.
  """
  def handle_cast({:remove_subscriber, pid}, {sub_list, ref, pinmap}) do
    new_sub_list = Enum.filter(sub_list, fn el -> el != pid end)
    {:noreply, {new_sub_list, ref, pinmap}}
  end

  @impl true
  @doc """
  turn gpio on or off.
  # Example
  iex> GenServer.cast(SprinklerPi.Control, {:set_state, :io_led_red, "off"})
  ... :ok
  """
  def handle_cast({:set_state, gpio, state}, {sub_list, ref, pinmap}) do
    gpio_ref = ref[gpio]
    state_int = if state == "on", do: 1, else: 0
    Circuits.GPIO.write(gpio_ref, state_int)
    {:noreply, {sub_list, ref, pinmap}}
  end

  @impl true
  def handle_info({:circuits_gpio, pin, timestamp, state}, {sub_list, ref, pinmap}) do
    Logger.info("SprinklerPi.Control - gpio event pin/state/ts #{pin}/#{state}/#{timestamp}")

    Enum.each(sub_list, fn subscriber ->
      gpio = pinmap[pin]
      nice_state = if state == 1, do: "on", else: "off"
      GenServer.cast(subscriber, {gpio, nice_state, timestamp})
    end)

    {:noreply, {sub_list, ref, pinmap}}
  end

  @impl true
  @doc """
  read current gpio state. result can be either "off" or "on"
  # Example
  iex> GenServer.call(SprinklerPi.Control, {:get_state, :io_led_red})
  ... "off"
  """
  def handle_call({:get_state, gpio}, _from, {sub_list, ref, pinmap}) do
    gpio_ref = ref[gpio]
    state = Circuits.GPIO.read(gpio_ref)
    nice_state = if state == 1, do: "on", else: "off"
    {:reply, nice_state, {sub_list, ref, pinmap}}
  end

  @doc """
  read gpio state
  # Example
  iex> SprinklerPi.Control.get_state(:io_motor)
  ... "off"
  """
  def get_state(gpio) do
    GenServer.call(SprinklerPi.Control, {:get_state, gpio})
  end

  @doc """
  write gpio state
  # Example
  iex> SprinklerPi.Control.set_state(:io_motor, "on")
  ... :ok
  """
  def set_state(gpio, state) do
    GenServer.cast(SprinklerPi.Control, {:set_state, gpio, state})
    :ok
  end

  @doc """
  add pid to gpio update subscriber list
  gpio-changes event message message example: (gpio, state, timestamp)
  * GenServer.cast(pid, {:io_motor, "on", 123456})
  * GenServer.cast(pid, {:io_button, "off", 123567}
  # Example
  iex> SprinklerPi.Control.add_subscriber(self)
  ... :ok
  """
  def add_subscriber(pid) do
    GenServer.cast(SprinklerPi.Control, {:add_subscriber, pid})
    :ok
  end

  @doc """
  remove pid from gpio update subscriber list
  # Example
  iex> SprinklerPi.Control.remove_subscriber(self)
  ... :ok
  """
  def remove_subscriber(pid) do
    GenServer.cast(SprinklerPi.Control, {:remove_subscriber, pid})
    :ok
  end
end
