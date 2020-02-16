defmodule SprinklerPi do
  @moduledoc """
  Documentation for SprinklerPi.
  """

  @doc """
  Hello world.

  ## Examples

      iex> SprinklerPi.hello
      :world

  """
  def hello do
    :world
  end

  def doit(gpio) do
    {:ok, gpio} = Circuits.GPIO.open(gpio, :output)

    Circuits.GPIO.write(gpio, 1)
    #Circuits.GPIO.close(gpio)
  end
  def stopit(gpio) do
    {:ok, gpio} = Circuits.GPIO.open(gpio, :output)

    Circuits.GPIO.write(gpio, 0)
    #Circuits.GPIO.close(gpio)
  end
end
