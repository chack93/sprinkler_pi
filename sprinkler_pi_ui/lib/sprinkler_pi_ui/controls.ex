defmodule SprinklerPiUi.Controls do
  @moduledoc """
  The Controls context.
  """

  alias SprinklerPiUi.Controls.Schedule

  @doc """
  Returns the list of schedules.

  ## Examples

  iex> list_schedules()
  [%Schedule{}, ...]

  """
  def list_schedules do
    [%Schedule{}]
  end

  @doc """
  Gets a single schedule.

  Raises `Ecto.NoResultsError` if the Schedule does not exist.

  ## Examples

  iex> get_schedule!(123)
  %Schedule{}

  iex> get_schedule!(456)
  ** (Ecto.NoResultsError)

  """
  def get_schedule!(id), do:      %Schedule{}

  @doc """
  Creates a schedule.

  ## Examples

  iex> create_schedule(%{field: value})
  {:ok, %Schedule{}}

  iex> create_schedule(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def create_schedule(attrs \\ %{}) do
    {:ok, %Schedule{}}
  end

  @doc """
  Updates a schedule.

  ## Examples

  iex> update_schedule(schedule, %{field: new_value})
  {:ok, %Schedule{}}

  iex> update_schedule(schedule, %{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def update_schedule(%Schedule{} = schedule, attrs) do
    {:ok, %Schedule{}}
  end

  @doc """
  Deletes a schedule.

  ## Examples

  iex> delete_schedule(schedule)
  {:ok, %Schedule{}}

  iex> delete_schedule(schedule)
  {:error, %Ecto.Changeset{}}

  """
  def delete_schedule(%Schedule{} = schedule) do
    {:ok, %Schedule{}}
  end
end
