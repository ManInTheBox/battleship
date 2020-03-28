defmodule Battleship.SquareTest do
  use ExUnit.Case, async: true

  test "creates a new Square" do
    assert {1, 5} == Battleship.Square.new({1, 5})
  end
end
