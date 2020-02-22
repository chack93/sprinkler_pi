defmodule SprinklerPiUiWeb.HelloController do
  use SprinklerPiUiWeb, :controller

  def hello(conn, _params) do
    conn
    |> assign(:page_title, "hello :)")
    |> assign(:text, "lol")
    |> render("hello.html")
  end
end
