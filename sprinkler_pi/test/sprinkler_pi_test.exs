defmodule SprinklerPiTest do
  use ExUnit.Case
  doctest SprinklerPi

  test "greets the world" do
    assert SprinklerPi.hello() == :world
  end
end
