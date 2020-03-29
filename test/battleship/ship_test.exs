defmodule Battleship.ShipTest do
  use ExUnit.Case, async: true

  test "creates new Submarine" do
    assert %Battleship.Ship{squares: [{1, 1}], name: "Submarine"} = Battleship.Ship.new({1, 1})
  end

  test "creates new Destroyer" do
    assert %Battleship.Ship{squares: [{1, 1}, {2, 1}], name: "Destroyer"} = Battleship.Ship.new({2, 1}, {1, 1})
  end

  test "creates new Cruiser" do
    assert %Battleship.Ship{squares: [{3, 4}, {4, 4}, {5, 4}], name: "Cruiser"} = Battleship.Ship.new({5, 4}, {3, 4}, {4, 4})
  end

  test "creates new Battleship" do
    assert %Battleship.Ship{squares: [{7, 10}, {8, 10}, {9, 10}, {10, 10}], name: "Battleship"} = Battleship.Ship.new({10, 10}, {7, 10}, {8, 10}, {9, 10})
  end

  test "errors when duplicate squares are provided" do
    assert {:error, :not_unique_squares} = Battleship.Ship.new({1, 1}, {1, 1})
  end

  test "errors when squares are not properly aligned" do
    assert {:error, :not_siblings} = Battleship.Ship.new({1, 1}, {10, 1})
  end
end
