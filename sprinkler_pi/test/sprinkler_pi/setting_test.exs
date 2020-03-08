defmodule SprinklerPi.SettingTest do
  use ExUnit.Case

  test "setting test" do
    SprinklerPi.Setting.set(%{
      "schedule" => [],
      "override_timeout_seconds" => 120,
      "filter_min_pump_time_seconds" => 5,
      "timezone" => "Etc/UTC"
    })

    assert %{
             "schedule" => [],
             "override_timeout_seconds" => 120,
             "filter_min_pump_time_seconds" => 5,
             "timezone" => "Etc/UTC"
           } == SprinklerPi.Setting.get()

    new_schedule = [
      {System.unique_integer(), 5, 13, 30, 120},
      {System.unique_integer(), 6, 14, 40, 240}
    ]

    assert %{
             "schedule" => new_schedule,
             "override_timeout_seconds" => 120,
             "filter_min_pump_time_seconds" => 5,
             "timezone" => "Europe/Vienna"
           } ==
             SprinklerPi.Setting.set(%{"schedule" => new_schedule, "timezone" => "Europe/Vienna"})

    assert %{
             "schedule" => new_schedule,
             "override_timeout_seconds" => 120,
             "filter_min_pump_time_seconds" => 5,
             "timezone" => "Europe/Vienna"
           } == SprinklerPi.Setting.get()
  end
end
