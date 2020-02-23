defmodule SprinklerPi.Control do
  @moduledoc """
  control hardware peripherals based on gpio pin config in SprinklerPi.Control.
  will broadcast gpio changes over Phoenix.PubSub topic "io-change"
  # Broadcast Example
  def handle_info({"io_change", :io_motor, "on", timestamp}, socket)
  """

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
end
