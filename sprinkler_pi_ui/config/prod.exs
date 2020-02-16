use Mix.Config

config :sprinkler_pi_ui, SprinklerPiUiWeb.Endpoint,
  url: [host: "sprinkler_pi.local", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

import_config "prod.secret.exs"
