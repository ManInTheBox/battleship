defmodule Battleship.Field do
  @x_axis [:A, :B, :C, :D, :E, :F, :G, :H, :I, :J]
  @y_axis 1..10

  def new({x, y}) when x in @x_axis and y in @y_axis, do: {x, y}
end
