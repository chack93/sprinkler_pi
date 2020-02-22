defmodule SprinklerPiUiWeb.ScheduleController do
  use SprinklerPiUiWeb, :controller

  alias SprinklerPiUi.Controls
  alias SprinklerPiUi.Controls.Schedule

  def index(conn, _params) do
    schedules = Controls.list_schedules()
    render(conn, "index.html", schedules: schedules)
  end

  def new(conn, _params) do
    #changeset = Controls.change_schedule(%Schedule{})
    changeset = %{}
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"schedule" => schedule_params}) do
    case Controls.create_schedule(schedule_params) do
      {:ok, schedule} ->
        conn
        |> put_flash(:info, "Schedule created successfully.")
        |> redirect(to: Routes.schedule_path(conn, :show, schedule))

      {:error,  changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    schedule = Controls.get_schedule!(id)
    render(conn, "show.html", schedule: schedule)
  end

  def edit(conn, %{"id" => id}) do
    schedule = Controls.get_schedule!(id)
    #changeset = Controls.change_schedule(schedule)
    changeset = %{}
    render(conn, "edit.html", schedule: schedule, changeset: changeset)
  end

  def update(conn, %{"id" => id, "schedule" => schedule_params}) do
    schedule = Controls.get_schedule!(id)

    case Controls.update_schedule(schedule, schedule_params) do
      {:ok, schedule} ->
        conn
        |> put_flash(:info, "Schedule updated successfully.")
        |> redirect(to: Routes.schedule_path(conn, :show, schedule))

      {:error, changeset} ->
        render(conn, "edit.html", schedule: schedule, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    schedule = Controls.get_schedule!(id)
    {:ok, _schedule} = Controls.delete_schedule(schedule)

    conn
    |> put_flash(:info, "Schedule deleted successfully.")
    |> redirect(to: Routes.schedule_path(conn, :index))
  end
end
