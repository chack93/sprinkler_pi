defmodule SprinklerPi.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: SprinklerPi.Supervisor]
    children =
      [
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: SprinklerPi.Worker.start_link(arg)
      # {SprinklerPi.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: SprinklerPi.Worker.start_link(arg)
      # {SprinklerPi.Worker, arg},
    ]
  end

  def target() do
    Application.get_env(:sprinkler_pi, :target)
  end
end
