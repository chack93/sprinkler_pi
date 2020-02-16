defmodule SprinklerPiUiWeb.ErrorView do
  use SprinklerPiUiWeb, :view

  # def render("404.html", _assigns) do
  #   "Not Found"
  # end

  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
