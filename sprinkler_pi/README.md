# SprinklerPi

Raspberry Pi controlled plant sprinkler

## create firmware


### set environment variable

```
# specify raspberry model
export MIX_TARGET=rpi0

# setup wifi to connect to
export NERVES_NETWORK_KEY_MGMT=WPA-PSK
export NERVES_NETWORK_SSID=INSERT_WIFI
export NERVES_NETWORK_PSK=INSERT_WIFI_PW

# generate secret key base for phoenix
export SECRET_KEY_BASE=INSERT_SKB
```

### create firmware sd card

```
MIX_ENV=prod mix firmware.burn
```

### update firmware remotely

```
MIX_ENV=prod mix firmware
MIX_ENV=prod ./upload.sh sprinkler_pi.local
```

