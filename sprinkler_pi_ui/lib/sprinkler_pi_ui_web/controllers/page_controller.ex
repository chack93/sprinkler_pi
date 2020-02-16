defmodule SprinklerPiUiWeb.PageController do
  use SprinklerPiUiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
