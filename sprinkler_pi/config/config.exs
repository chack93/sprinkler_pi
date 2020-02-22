import Config

import_config "../../sprinkler_pi_ui/config/config.exs"

config :sprinkler_pi_ui, SprinklerPiUiWeb.Endpoint,
  url: [host: "sprinkler_pi.local", port: 80],
  code_reloader: Mix.env == :dev,
  http: [port: 80],
  load_from_system_env: false,
  server: true

config :sprinkler_pi, target: Mix.target()

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :nerves, source_date_epoch: "1581777418"

if Mix.env != :dev do
  config :logger, backends: [RingLogger]
end

if Mix.target() != :host do
  import_config "target.exs"
end
