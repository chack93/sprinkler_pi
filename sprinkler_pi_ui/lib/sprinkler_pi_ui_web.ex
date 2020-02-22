defmodule SprinklerPiUiWeb do
  @moduledoc """
  SprinklerPiUiWeb module
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: SprinklerPiUiWeb

      import Plug.Conn
      import SprinklerPiUiWeb.Gettext
      alias SprinklerPiUiWeb.Router.Helpers, as: Routes
      import Phoenix.LiveView.Helpers
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/sprinkler_pi_ui_web/templates",
        namespace: SprinklerPiUiWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import SprinklerPiUiWeb.ErrorHelpers
      import SprinklerPiUiWeb.Gettext
      alias SprinklerPiUiWeb.Router.Helpers, as: Routes
      import Phoenix.LiveView.Helpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import SprinklerPiUiWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
