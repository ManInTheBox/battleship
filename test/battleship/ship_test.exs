defmodule Battleship.ShipTest do
  use ExUnit.Case, async: true

  test "creates new Submarine" do
    assert [{1, 1}] = Battleship.Ship.new({1, 1})
  end

  test "creates new Destroyer" do
    assert [{1, 1}, {2, 1}] = Battleship.Ship.new({2, 1}, {1, 1})
  end

  test "creates new Cruiser" do
    assert [{3, 4}, {4, 4}, {5, 4}] = Battleship.Ship.new({5, 4}, {3, 4}, {4, 4})
  end

  test "creates new Battleship" do
    assert [{7, 10}, {8, 10}, {9, 10}, {10, 10}] = Battleship.Ship.new({10, 10}, {7, 10}, {8, 10}, {9, 10})
  end

  test "errors when duplicate squares are provided" do
    assert {:error, :not_unique_squares} = Battleship.Ship.new({1, 1}, {1, 1})
  end

  test "errors when squares are not properly aligned" do
    assert {:error, :not_siblings} = Battleship.Ship.new({1, 1}, {10, 1})
  end
end
