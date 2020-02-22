defmodule SprinklerPiUi.Repo.Migrations.CreateSchedules do
  use Ecto.Migration

  def change do
    create table(:schedules) do
      add :time, :string

      timestamps()
    end

  end
end
