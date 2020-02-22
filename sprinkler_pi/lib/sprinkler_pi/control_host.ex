defmodule SprinklerPi.ControlHost do
  @moduledoc """
  mock `SprinklerPi.ControlTarget` for testing on host
  will broadcast gpio changes over Phoenix.PubSub topic "io_change"
  # Broadcast Example
  def handle_info({"io_change", :io_motor, "on", timestamp}, socket)
  """

  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: SprinklerPi.Control)
  end

  @impl true
  def init(_) do
    {:ok,
     %{
       :io_motor => "off",
       :io_valve => "off",
       :io_led_red => "off",
       :io_led_green => "off",
       :io_button => "off",
       :io_water_sensor => "off"
     }}
  end

  @impl true
  @doc """
  turn gpio on or off.
  # Example
  iex> GenServer.cast(SprinklerPi.Control, {:set_state, :io_led_red, "off"})
  ... :ok
  """
  def handle_cast({:set_state, gpio, state}, state_map) do
    Logger.info("SprinklerPi.ControlHost - :set_state #{gpio}->#{state}")
    new_state_map = Map.put(state_map, gpio, state)

    timestamp = DateTime.to_unix(DateTime.utc_now(), :microsecond)
    Phoenix.PubSub.broadcast(SprinklerPiUi.PubSub, "io_change", {"io_change",gpio, state, timestamp})

    {:noreply, new_state_map}
  end

  @impl true
  @doc """
  read current gpio state. result can be either "off" or "on"
  # Example
  iex> GenServer.call(SprinklerPi.Control, {:get_state, :io_led_red})
  ... "off"
  """
  def handle_call({:get_state, gpio}, _from, state_map) do
    state = state_map[gpio]
    Logger.info("SprinklerPi.ControlHost - :get_state #{gpio}->#{state}")
    {:reply, state, state_map}
  end
end
