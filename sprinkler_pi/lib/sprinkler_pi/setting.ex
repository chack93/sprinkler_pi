defmodule SprinklerPi.Setting do
  @moduledoc """
  read/write settings
  # Broadcast setting changes on topic "setting"
  def handle_info({"setting-change", %{"schedule": [], ...}, timestamp}, state)
  """
  use GenServer
  @setting_filename if Mix.env() == :prod, do: "/root/sprinkler_pi_setting.json", else: "./sprinkler_pi_setting.json"

  @default_setting %{
    "schedule" => [],
    "override_timeout_seconds" => 120,
    "filter_min_pump_time_seconds" => 5,
    "timezone" => "Etc/UTC"
  }

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: SprinklerPi.Setting)
  end

  @impl true
  def init(_) do
    setting =
      if File.exists?(@setting_filename) do
        {:ok, file} = File.read(@setting_filename)
        {:ok, setting} = Jason.decode(file)
        schedule = Enum.map(setting["schedule"], fn el -> List.to_tuple(el) end)
        setting = Map.merge(setting, %{"schedule" => schedule})
        Map.merge(@default_setting, setting)
      else
        schedule = Enum.map(@default_setting["schedule"], fn el -> Tuple.to_list(el) end)
        setting_tuple_replaced = Map.merge(@default_setting, %{"schedule" => schedule})
        {:ok, setting_string} = Jason.encode(setting_tuple_replaced)
        File.write(@setting_filename, setting_string)
        @default_setting
      end

    {:ok, setting}
  end

  @doc """
  get setting
  # Example
  iex> SprinklerPi.Setting.get()
  ... %{ "schedule" => [{1, 23, 59, 120}], "override_timeout_seconds" => 120, "filter_min_pump_time_seconds" => 5, "timezone" => "Etc/UTC" }
  """
  def get() do
    GenServer.call(SprinklerPi.Setting, {:get})
  end

  @doc """
  set setting. map-merge parts, then writes to file
  # Example
  iex> SprinklerPi.Setting.set(%{:override_timeout_seconds => 60})
  ... %{ "schedule" => [{1, 23, 59, 120}], "override_timeout_seconds" => 60, "filter_min_pump_time_seconds" => 5, "timezone" => "Etc/UTC" }
  """
  def set(map) do
    GenServer.call(SprinklerPi.Setting, {:set, map})
  end

  @impl true
  @doc """
  get setting
  """
  def handle_call({:get}, _from, setting) do
    {:reply, setting, setting}
  end

  @impl true
  @doc """
  set setting
  """
  def handle_call({:set, new_setting}, _from, setting) do
    setting = Map.merge(setting, new_setting)
    schedule = Enum.map(setting["schedule"], fn el -> Tuple.to_list(el) end)
    setting_tuple_replaced = Map.merge(setting, %{"schedule" => schedule})

    {:ok, setting_string} = Jason.encode(setting_tuple_replaced)
    File.write(@setting_filename, setting_string)

    Phoenix.PubSub.broadcast(
      SprinklerPiUi.PubSub,
      "setting",
      {"setting-change", setting, DateTime.to_unix(DateTime.utc_now())}
    )
    {:reply, setting, setting}
  end
end
