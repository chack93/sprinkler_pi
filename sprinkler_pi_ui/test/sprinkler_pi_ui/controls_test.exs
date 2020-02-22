defmodule SprinklerPiUi.ControlsTest do
  use SprinklerPiUi.DataCase

  alias SprinklerPiUi.Controls

  describe "schedules" do
    alias SprinklerPiUi.Controls.Schedule

    @valid_attrs %{time: "some time"}
    @update_attrs %{time: "some updated time"}
    @invalid_attrs %{time: nil}

    def schedule_fixture(attrs \\ %{}) do
      {:ok, schedule} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Controls.create_schedule()

      schedule
    end

    test "list_schedules/0 returns all schedules" do
      schedule = schedule_fixture()
      assert Controls.list_schedules() == [schedule]
    end

    test "get_schedule!/1 returns the schedule with given id" do
      schedule = schedule_fixture()
      assert Controls.get_schedule!(schedule.id) == schedule
    end

    test "create_schedule/1 with valid data creates a schedule" do
      assert {:ok, %Schedule{} = schedule} = Controls.create_schedule(@valid_attrs)
      assert schedule.time == "some time"
    end

    test "create_schedule/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Controls.create_schedule(@invalid_attrs)
    end

    test "update_schedule/2 with valid data updates the schedule" do
      schedule = schedule_fixture()
      assert {:ok, %Schedule{} = schedule} = Controls.update_schedule(schedule, @update_attrs)
      assert schedule.time == "some updated time"
    end

    test "update_schedule/2 with invalid data returns error changeset" do
      schedule = schedule_fixture()
      assert {:error, %Ecto.Changeset{}} = Controls.update_schedule(schedule, @invalid_attrs)
      assert schedule == Controls.get_schedule!(schedule.id)
    end

    test "delete_schedule/1 deletes the schedule" do
      schedule = schedule_fixture()
      assert {:ok, %Schedule{}} = Controls.delete_schedule(schedule)
      assert_raise Ecto.NoResultsError, fn -> Controls.get_schedule!(schedule.id) end
    end

    test "change_schedule/1 returns a schedule changeset" do
      schedule = schedule_fixture()
      assert %Ecto.Changeset{} = Controls.change_schedule(schedule)
    end
  end
end
