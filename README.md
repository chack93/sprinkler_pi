# sprinkler_pi

Raspberry Pi controlled plant sprinkler.

## files

### sprinkler_pi

contains pump & sensor controller.

### sprinkler_pi_ui

is a phoenix server providing a website to control the sprinkler system.

### hardware

contains the kicad project of the used circuit.
led's, manual override button & water level sensor are supplied by the raspberry (3.3V).  
pump & solenoid powered valve need to be powered by an external 12V power supply. the power supply need to be powerful enought to support both water pump & solenoid, as well as momentary inrush current on power on.  
most water pump can't pump air well, therefore a solenoid valve is attached right after the pump output to stop backflow. the valve need to be normally closed for this to work.

## building
```
cd sprinkler_pi

# specify raspberry model (raspberry zero in this case)
export MIX_TARGET=rpi0

# setup wifi to connect to
export NERVES_NETWORK_KEY_MGMT=WPA-PSK
export NERVES_NETWORK_SSID=INSERT_WIFI
export NERVES_NETWORK_PSK=INSERT_WIFI_PW

# fetch dependencies
mix deps.get

# generate secret key base for phoenix
mix phx.gen.secret
# copy & paste generated secret
export SECRET_KEY_BASE=INSERT_SKB

# generate image & burn on attached sd-card
MIX_ENV=prod mix firmware.burn
```
