use Mix.Config

config :sprinkler_pi_ui, SprinklerPiUiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/1mXV2Wn9Fob4JC9c4NcWPWThH358ezUzxs0oFrDljVpQAxvAJ3zFUlR7l4f58rx",
  render_errors: [view: SprinklerPiUiWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: SprinklerPiUi.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "Kd0d+XFG"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
