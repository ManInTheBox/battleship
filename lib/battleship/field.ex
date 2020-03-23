defmodule Battleship.Field do
  require Logger

  @x_axis [:A, :B, :C, :D, :E, :F, :G, :H, :I, :J]
  @y_axis 1..10

  def new(x, y) when x in @x_axis and y in @y_axis do
    Logger.debug("Created field {#{inspect(x)},#{inspect(y)}}")
    {x, y}
  end
end
