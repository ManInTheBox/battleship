defmodule Battleship.Square do
  @matrix 1..10

  def new({x, y}) when x in @matrix and y in @matrix, do: {x, y}
end
