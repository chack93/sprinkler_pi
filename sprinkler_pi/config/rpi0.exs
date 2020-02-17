import Config

config :sprinkler_pi,
  io_motor: {23, :output, 0},
  io_valve: {24, :output, 0},
  io_button: {4, :input, 0},
  io_water_sensor: {17, :input, 0},
  io_led_red: {27, :output, 0},
  io_led_green: {22, :output, 0}
