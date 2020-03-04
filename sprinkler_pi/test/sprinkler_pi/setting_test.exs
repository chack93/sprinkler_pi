defmodule SprinklerPi.SettingTest do
  use ExUnit.Case

  test "setting test" do
    SprinklerPi.Setting.set(%{"schedule" => []})

    assert %{
             "schedule" => [],
             "override_timeout_seconds" => 120,
             "filter_min_pump_time_seconds" => 5
           } == SprinklerPi.Setting.get()

    new_schedule = [
      {System.unique_integer(), 5, 13, 30, 120},
      {System.unique_integer(), 6, 14, 40, 240}
    ]

    assert %{
             "schedule" => new_schedule,
             "override_timeout_seconds" => 120,
             "filter_min_pump_time_seconds" => 5
           } ==
             SprinklerPi.Setting.set(%{"schedule" => new_schedule})

    assert %{
             "schedule" => new_schedule,
             "override_timeout_seconds" => 120,
             "filter_min_pump_time_seconds" => 5
           } == SprinklerPi.Setting.get()
  end
end
