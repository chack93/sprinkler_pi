defmodule SprinkerPiTest do
  use ExUnit.Case
  doctest SprinkerPi

  test "greets the world" do
    assert SprinkerPi.hello() == :world
  end
end
