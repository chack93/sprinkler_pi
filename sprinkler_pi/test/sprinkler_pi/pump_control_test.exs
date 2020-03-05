defmodule SprinklerPi.PumpControlTest do
  use ExUnit.Case, async: false

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

  test "activate pump water ok", _ do
    Phoenix.PubSub.subscribe(SprinklerPiUi.PubSub, "pump-control")

    assert :ok == SprinklerPi.Control.set_state(:io_water_sensor, "on")
    assert false == SprinklerPi.PumpControl.active?()
    assert {:ok, nil} == SprinklerPi.PumpControl.error()

    # on
    assert :ok == SprinklerPi.PumpControl.on()
    assert "on" == SprinklerPi.Control.get_state(:io_motor)
    assert "on" == SprinklerPi.Control.get_state(:io_valve)
    assert "on" == SprinklerPi.Control.get_state(:io_led_green)
    assert true == SprinklerPi.PumpControl.active?()

    receive do
      {"pump-error", {:ok, nil}, _ts} ->nil
      e -> flunk("wrong event sent #{inspect(e)}")
    after
      1 ->
        flunk("no event sent")
    end

    receive do
      {"pump-change", true, _ts} -> nil
      e -> flunk("wrong event sent #{inspect(e)}")
    after
      1 ->
        flunk("no event sent")
    end

    # off
    assert :ok == SprinklerPi.PumpControl.off()
    assert "off" == SprinklerPi.Control.get_state(:io_motor)
    assert "off" == SprinklerPi.Control.get_state(:io_valve)
    assert "off" == SprinklerPi.Control.get_state(:io_led_green)
    assert false == SprinklerPi.PumpControl.active?()

    receive do
      {"pump-change", false, _ts} -> nil
      e -> flunk("wrong event sent #{inspect(e)}")
    after
      1 ->
        flunk("no event sent")
    end
  end

  test "activate pump water low", _ do
    Phoenix.PubSub.subscribe(SprinklerPiUi.PubSub, "pump-control")

    :timer.sleep(100)
    assert :ok == SprinklerPi.Control.set_state(:io_water_sensor, "on")
    :timer.sleep(100)
    assert :ok == SprinklerPi.Control.set_state(:io_water_sensor, "off")
    :timer.sleep(100)

    receive do
      {"pump-error", {:ok, nil}, _ts} ->nil
      e -> flunk("wrong event sent #{inspect(e)}")
    after
      1 ->
        flunk("no event sent")
    end
    receive do
      {"pump-error", {:error, "water-low"}, _ts} -> nil
      e -> flunk("wrong event sent #{inspect(e)}")
    after
      1 ->
        flunk("no event sent")
    end

    assert false == SprinklerPi.PumpControl.active?()
    assert {:error, "water-low"} == SprinklerPi.PumpControl.error()
    assert :error == SprinklerPi.PumpControl.on()
    assert "off" == SprinklerPi.Control.get_state(:io_motor)
    assert "off" == SprinklerPi.Control.get_state(:io_valve)
    assert "off" == SprinklerPi.Control.get_state(:io_led_green)
    assert false == SprinklerPi.PumpControl.active?()
  end
end
