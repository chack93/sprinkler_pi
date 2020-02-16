defmodule SprinklerPiUiWeb.ConnCase do

  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.ConnTest
      alias SprinklerPiUiWeb.Router.Helpers, as: Routes

      @endpoint SprinklerPiUiWeb.Endpoint
    end
  end

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
