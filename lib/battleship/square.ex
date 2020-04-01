defmodule Battleship.Square do
  @grid Battleship.Grid.dimensions()

  def new({x, y}) when x in @grid and y in @grid, do: {x, y}
end
