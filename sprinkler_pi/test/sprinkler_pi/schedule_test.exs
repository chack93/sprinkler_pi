defmodule SprinklerPi.ScheduleTest do
  use ExUnit.Case

  setup_all do
    schedule = [
      {1, 3, 12, 40, 120},
      {2, 2, 12, 30, 120},
      {3, 1, 11, 00, 120},
      {4, 6, 23, 59, 240},
      {5, 7, 23, 59, 240}
    ]

    SprinklerPi.Setting.set(%{"schedule" => schedule})
    {:ok, %{:schedule => schedule}}
  end

  test "filter active schedule", %{:schedule => schedule} do
    # tuesday
    assert {2, 2, 12, 30, 120} ==
             SprinklerPi.Schedule.filter_active(schedule, ~N[2020-02-25 12:30:00], nil)

    assert {2, 2, 12, 30, 120} ==
             SprinklerPi.Schedule.filter_active(schedule, ~N[2020-02-25 12:31:59], nil)

    assert {4, 6, 23, 59, 240} ==
             SprinklerPi.Schedule.filter_active(schedule, ~N[2020-02-29 23:59:30], nil)

    assert {4, 6, 23, 59, 240} ==
             SprinklerPi.Schedule.filter_active(schedule, ~N[2020-03-01 00:00:10], nil)

    assert nil ==
             SprinklerPi.Schedule.filter_active(schedule, ~N[2020-03-01 00:03:01], nil)

    assert {5, 7, 23, 59, 240} ==
             SprinklerPi.Schedule.filter_active(schedule, ~N[2020-03-01 23:59:30], nil)

    assert {5, 7, 23, 59, 240} ==
             SprinklerPi.Schedule.filter_active(schedule, ~N[2020-03-02 00:00:10], nil)

    assert nil ==
             SprinklerPi.Schedule.filter_active(schedule, ~N[2020-03-02 00:03:01], nil)

    assert nil ==
             SprinklerPi.Schedule.filter_active(schedule, ~N[2020-02-25 13:30:00], nil)

    assert nil ==
             SprinklerPi.Schedule.filter_active(schedule, ~N[2020-02-25 12:30:00], true)

    assert nil ==
             SprinklerPi.Schedule.filter_active(schedule, ~N[2020-02-25 12:30:00], false)
  end

  test "filter next schedule", %{:schedule => schedule} do
    # saturday
    assert {4, 6, 23, 59, 240} ==
             SprinklerPi.Schedule.filter_next(schedule, ~N[2020-02-29 12:30:00])

    # tuesday
    assert {1, 3, 12, 40, 120} ==
             SprinklerPi.Schedule.filter_next(schedule, ~N[2020-02-25 12:41:00])
  end

  test "get/set override", _ do
    Phoenix.PubSub.subscribe(SprinklerPiUi.PubSub, "schedule")

    assert :ok == SprinklerPi.Schedule.set_override(true)

    receive do
      {"manual-override", true, _datetime, _ts} -> nil
      e -> flunk("wrong event sent #{inspect(e)}")
    after
      100 ->
        flunk("no event sent")
    end

    assert {true, ts} = SprinklerPi.Schedule.get_override()

    assert :ok == SprinklerPi.Schedule.set_override(false)

    receive do
      {"manual-override", false, _datetime, _ts} -> nil
      e -> flunk("wrong event sent #{inspect(e)}")
    after
      100 ->
        flunk("no event sent")
    end

    assert {false, _} = SprinklerPi.Schedule.get_override()

    assert :ok == SprinklerPi.Schedule.set_override(nil)

    receive do
      {"manual-override", nil, _datetime, _ts} -> nil
      e -> flunk("wrong event sent #{inspect(e)}")
    after
      100 ->
        flunk("no event sent")
    end

    assert {nil, _} = SprinklerPi.Schedule.get_override()
  end
end
