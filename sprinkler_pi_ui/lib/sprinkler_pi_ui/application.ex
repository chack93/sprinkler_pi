defmodule SprinklerPiUi.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      SprinklerPiUiWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: SprinklerPiUi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    SprinklerPiUiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
