defmodule SprinklerPi.ControlTest do
  use ExUnit.Case

  setup_all do
    SprinklerPi.Control.set_state(:io_motor, "off")
    SprinklerPi.Control.set_state(:io_valve, "off")
    SprinklerPi.Control.set_state(:io_button, "off")
    SprinklerPi.Control.set_state(:io_water_sensor, "off")
    SprinklerPi.Control.set_state(:io_led_red, "off")
    SprinklerPi.Control.set_state(:io_led_green, "off")
    :timer.sleep(100)
    {:ok, []}
  end

  test "set/get state", _ do
    Phoenix.PubSub.subscribe(SprinklerPiUi.PubSub, "io-change")
    assert "off" == SprinklerPi.Control.get_state(:io_motor)
    assert :ok == SprinklerPi.Control.set_state(:io_motor, "on")
    assert "on" == SprinklerPi.Control.get_state(:io_motor)

    receive do
      {"io_change", :io_motor, "on", _ts} -> nil
      e -> flunk("wrong event sent #{inspect(e)}")
    after
      1 ->
        flunk("no event sent")
    end
  end
end
