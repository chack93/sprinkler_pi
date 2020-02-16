defmodule SprinklerPi.ControlTest do
  use ExUnit.Case
  doctest SprinklerPi.Control

  test "greets the world" do
    assert SprinklerPi.hello() == :world
  end
end
