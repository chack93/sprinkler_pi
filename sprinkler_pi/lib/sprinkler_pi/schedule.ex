defmodule SprinklerPi.Schedule do
  @moduledoc """
  activate/deactivate pump control based on schedule or manual-override.
  will broadcast manual-override on/off on topic "schedule"
  # Broadcast activate schedule Example
  def handle_info({"schedule-activate" {2, 23, 59, 30}, timestamp}, state)
  # Broadcast override Example on/off/reset true/false/nil
  def handle_info({"manual-override" true, override_start_date_time, timestamp}, state)
  """
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: SprinklerPi.Schedule)
  end

  @impl true
  def init(_) do
    override = nil
    override_start = nil
    Process.send_after(self(), :check_schedule, 1000)
    {:ok, {override, override_start}}
  end

  @doc """
  get active schedule
  result: {week_of_day, hour, minute, duration_in_seconds}
  nil if none active or override
  # Example
  iex> SprinklerPi.Schedule.active()
  ... {7, 11, 45, 240}
  """
  def active() do
    GenServer.call(SprinklerPi.Schedule, {:active})
  end

  @doc """
  get next schedule
  result: {week_of_day, hour_of_day, minute_of_day, duration_in_seconds}
  # Example
  iex> SprinklerPi.Schedule.next_schedule()
  ... {1, 10, 59, 120}
  """
  def next_schedule() do
    GenServer.call(SprinklerPi.Schedule, {:next_schedule})
  end

  @doc """
  get manual override
  response:
  {state, timestamp}
  state: true/false/nil -> on/off/inactive
  timestamp: override start utc-DateTime
  # Example
  iex> SprinklerPi.Schedule.get_override()
  ... {true, 98712345}
  """
  def get_override() do
    GenServer.call(SprinklerPi.Schedule, {:get_override})
  end

  @doc """
  set manual override on/off/reset true/false/nil
  # Example
  iex> SprinklerPi.Schedule.set_override(true)
  ... :ok
  """
  def set_override(state) do
    GenServer.cast(SprinklerPi.Schedule, {:set_override, state})
  end

  @doc false
  @impl true
  def handle_call({:active}, _from, {override, override_start}) do
    %{"schedule" => schedule} = SprinklerPi.Setting.get()
    active = filter_active(schedule, NaiveDateTime.local_now(), override)
    {:reply, active, {override, override_start}}
  end

  @doc false
  @impl true
  def handle_call({:next_schedule}, _from, {override, override_start}) do
    %{"schedule" => schedule} = SprinklerPi.Setting.get()
    next = filter_next(schedule, NaiveDateTime.local_now())

    {:reply, next, {override, override_start}}
  end

  @doc false
  @impl true
  def handle_call({:get_override}, _from, {override, override_start}) do
    {:reply, {override, override_start}, {override, override_start}}
  end

  @doc false
  @impl true
  def handle_cast({:set_override, override}, {_, _}) do
    override_start =
      cond do
        override == true ->
          SprinklerPi.PumpControl.on()
          DateTime.utc_now()

        override == false ->
          SprinklerPi.PumpControl.off()
          DateTime.utc_now()

        true ->
          nil
      end

    Phoenix.PubSub.broadcast(
      SprinklerPiUi.PubSub,
      "schedule",
      {"manual-override", override, override_start,
       DateTime.to_unix(DateTime.utc_now(), :millisecond)}
    )

    {:noreply, {override, override_start}}
  end

  @doc false
  @impl true
  def handle_info(
        :check_schedule,
        {override, override_start}
      ) do
    %{"schedule" => schedule, "override_timeout_seconds" => override_timeout_seconds} =
      SprinklerPi.Setting.get()

    utc_now = DateTime.utc_now()
    # disable override
    {override, override_start} =
      if override != nil and DateTime.diff(utc_now, override_start) > override_timeout_seconds do
        Phoenix.PubSub.broadcast(
          SprinklerPiUi.PubSub,
          "schedule",
          {"manual-override", nil, nil, DateTime.to_unix(DateTime.utc_now(), :millisecond)}
        )

        {nil, nil}
      else
        {override, override_start}
      end

    active_schedule = filter_active(schedule, NaiveDateTime.local_now(), override)
    pump_active = SprinklerPi.PumpControl.active?()

    cond do
      active_schedule != nil and !pump_active and override == nil ->
        Logger.info("SprinklerPi.Schedule - :check_schedule activate pump")
        SprinklerPi.PumpControl.on()

        Phoenix.PubSub.broadcast(
          SprinklerPiUi.PubSub,
          "schedule",
          {"schedule-activate", active_schedule, utc_now}
        )

      active_schedule == nil and pump_active and override == nil ->
        Logger.info("SprinklerPi.Schedule - :check_schedule deactivate pump")
        SprinklerPi.PumpControl.off()

        Phoenix.PubSub.broadcast(
          SprinklerPiUi.PubSub,
          "schedule",
          {"schedule-activate", active_schedule, utc_now}
        )

      true ->
        nil
    end

    Process.send_after(self(), :check_schedule, 1000)
    {:noreply, {override, override_start}}
  end

  def filter_active(_, _, true), do: nil
  def filter_active(_, _, false), do: nil

  def filter_active(schedule, current_time, nil) do
    %{
      :year => year,
      :month => month,
      :day => day
    } = current_time

    weekday = Calendar.ISO.day_of_week(year, month, day)

    now = Map.merge(current_time, %{:day => weekday})

    schedule
    |> Enum.filter(fn {w, h, m, duration} ->
      sch_start = Map.merge(now, %{:day => w, :hour => h, :minute => m, :second => 0})
      sch_end = NaiveDateTime.add(sch_start, duration, :second)

      # in case schedule stretches sunday->monday & now passes midnight
      # fix now for accurate comparison
      now =
        if sch_start.day == 7 and sch_end.day == 8 and now.day == 1,
          do: Map.merge(now, %{:day => 8}),
          else: now

      cmp_start = NaiveDateTime.compare(sch_start, now)
      cmp_end = NaiveDateTime.compare(now, sch_end)

      cond do
        cmp_start == :lt and cmp_end == :lt -> true
        cmp_start == :lt and cmp_end == :eq -> true
        cmp_start == :eq and cmp_end == :eq -> true
        cmp_start == :eq and cmp_end == :lt -> true
        true -> false
      end
    end)
    |> Enum.at(0)
  end

  def filter_next(schedule, current_time) do
    %{
      :year => year,
      :month => month,
      :day => day,
      :minute => minute,
      :hour => hour
    } = current_time

    weekday = Calendar.ISO.day_of_week(year, month, day)
    now = weekday * 1000 + hour * 100 + minute

    schedule
    |> Enum.sort_by(fn {w, h, m, _} ->
      base = w * 1000 + h * 100 + m
      past_factor = if base < now, do: 7000, else: 0
      base + past_factor
    end)
    |> Enum.at(0)
  end
end
