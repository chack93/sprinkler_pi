defmodule SprinklerPi.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: SprinklerPi.Supervisor]
    children = [SprinklerPi.PumpControl, SprinklerPi.Setting, SprinklerPi.Schedule] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  def children(:host) do
    [
      {SprinklerPi.ControlHost, nil}
    ]
  end

  def children(_target) do
    [
      {SprinklerPi.ControlTarget, nil}
    ]
  end

  def target() do
    Application.get_env(:sprinkler_pi, :target)
  end
end
