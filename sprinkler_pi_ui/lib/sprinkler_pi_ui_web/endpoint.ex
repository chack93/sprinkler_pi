defmodule SprinklerPiUiWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :sprinkler_pi_ui

  @session_options [
    store: :cookie,
    key: "_sprinkler_pi_ui_key",
    signing_salt: "RiZT2id9"
  ]

  socket "/socket", SprinklerPiUiWeb.UserSocket,
    websocket: true,
    longpoll: false
  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]]

  plug Plug.Static,
    at: "/",
    from: :sprinkler_pi_ui,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt
      apple-touch-icon.png
      android-chrome-192x192.png
      android-chrome-256x256.png
      browserconfig.xml
      favicon-16x16.png
      favicon-32x32.png
      favicon.ico
      favicon.png
      images
      mstile-150x150.png
      robots.txt
      safari-pinned-tab.svg
      site.webmanifest
    )

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug SprinklerPiUiWeb.Router
end
