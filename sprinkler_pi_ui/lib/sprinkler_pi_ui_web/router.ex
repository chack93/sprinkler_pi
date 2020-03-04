defmodule SprinklerPiUiWeb.Router do
  use SprinklerPiUiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug Phoenix.LiveView.Flash
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SprinklerPiUiWeb do
    pipe_through :browser

    live "/", DashboardLive
    live "/dashboard", DashboardLive
    live "/about", AboutLive
    live "/schedule", ScheduleLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", SprinklerPiUiWeb do
  #   pipe_through :api
  # end
end
