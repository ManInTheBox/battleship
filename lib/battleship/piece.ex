defmodule Battleship.Piece do
  def new(field1), do: [field1]
  def new(field1, field2), do: [field1, field2]
  def new(field1, field2, field3), do: [field1, field2, field3]
  def new(field1, field2, field3, field4), do: [field1, field2, field3, field4]

  def name(_), do: "Submarine"
  def name(_, _), do: "Destroyer"
  def name(_, _, _), do: "Cruiser"
  def name(_, _, _, _), do: "Battleship"
end
