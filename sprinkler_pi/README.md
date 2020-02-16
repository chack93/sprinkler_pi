# SprinklerPi

Raspberry Pi controlled plant sprinkler

## create firmware


### set environment variable

`
# specify raspberry model
export MIX_TARGET=rpi0
# setup wifi to connect to
export NERVES_NETWORK_KEY_MGMT=WPA-PSK
export NERVES_NETWORK_SSID=INSERT_WIFI
export NERVES_NETWORK_PSK=INSERT_WIFI_PW
# generate secret key base for phoenix
export SECRET_KEY_BASE=INSERT_SKB
`

### create firmware sd card

`
MIX_ENV=prod mix firmware.burn
`

### update firmware remotely

`
MIX_ENV=prod mix firmware
MIX_ENV=prod ./upload.sh sprinkler_pi.local
`

## getting started

To start your Nerves app:
  * `export MIX_TARGET=my_target` or prefix every command with
    `MIX_TARGET=my_target`. For example, `MIX_TARGET=rpi0`
  * Install dependencies with `mix deps.get`
  * Create firmware with `mix firmware`
  * Burn to an SD card with `mix firmware.burn`

## targets

Nerves applications produce images for hardware targets based on the
`MIX_TARGET` environment variable. If `MIX_TARGET` is unset, `mix` builds an
image that runs on the host (e.g., your laptop). This is useful for executing
logic tests, running utilities, and debugging. Other targets are represented by
a short name like `rpi3` that maps to a Nerves system image for that platform.
All of this logic is in the generated `mix.exs` and may be customized. For more
information about targets see:

https://hexdocs.pm/nerves/targets.html#content

