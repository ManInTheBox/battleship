defmodule Battleship.GridTest do
  use ExUnit.Case, async: true

  test "new ships can be added" do
    submarine = Battleship.Ship.new(Battleship.Square.new({10, 10}))
    assert [{{{10, 10}, :alive}}] = Battleship.Grid.add_ship(Battleship.Grid.new(), submarine)
  end

  test "errors when all ships are already arranged" do
    Enum.each(ships_arranged_data_provider(), fn {grid, ship, type} ->
      assert {:error, :ships_arranged, ^type} = Battleship.Grid.add_ship(grid, ship)
    end)
  end

  test "errors when ships overlap" do
    submarine = Battleship.Ship.new(Battleship.Square.new({10, 10}))

    destroyer =
      Battleship.Ship.new(
        Battleship.Square.new({9, 10}),
        Battleship.Square.new({10, 10})
      )

    assert {:error, :ships_overlap, {{9, 10}, {10, 10}}} =
             Battleship.Grid.new()
             |> Battleship.Grid.add_ship(submarine)
             |> Battleship.Grid.add_ship(destroyer)
  end

  test "errors when ships are touching each other" do
    submarine = Battleship.Ship.new(Battleship.Square.new({10, 10}))

    destroyer =
      Battleship.Ship.new(
        Battleship.Square.new({9, 8}),
        Battleship.Square.new({9, 9})
      )

    assert {:error, :ships_touching_each_other, {{9, 8}, {9, 9}}} =
             Battleship.Grid.new()
             |> Battleship.Grid.add_ship(submarine)
             |> Battleship.Grid.add_ship(destroyer)
  end

  test "fire torpedo miss" do
    grid = create_grid()
    assert {:water, {{10, 10}, :water}, grid} = Battleship.Grid.fire_torpedo(grid, {10, 10})
  end

  test "fire torpedo hit" do
    grid = create_grid()
    assert {:hit, {{1, 3}, :hit}, grid} = Battleship.Grid.fire_torpedo(grid, {1, 3})
  end

  test "fire torpedo sunk" do
    grid = create_grid()
    assert {:sunk, {{{1, 1}, :sunk}}, grid} = Battleship.Grid.fire_torpedo(grid, {1, 1})
    assert {:hit, {{1, 3}, :hit}, grid} = Battleship.Grid.fire_torpedo(grid, {1, 3})

    assert {:sunk, {{{1, 3}, :sunk}, {{1, 4}, :sunk}}, grid} =
             Battleship.Grid.fire_torpedo(grid, {1, 4})
  end

  defp ships_arranged_data_provider() do
    submarine = Battleship.Ship.new(Battleship.Square.new({10, 10}))

    destroyer =
      Battleship.Ship.new(
        Battleship.Square.new({8, 10}),
        Battleship.Square.new({7, 10})
      )

    cruiser =
      Battleship.Ship.new(
        Battleship.Square.new({5, 10}),
        Battleship.Square.new({4, 10}),
        Battleship.Square.new({3, 10})
      )

    battleship =
      Battleship.Ship.new(
        Battleship.Square.new({3, 8}),
        Battleship.Square.new({4, 8}),
        Battleship.Square.new({5, 8}),
        Battleship.Square.new({6, 8})
      )

    grid = create_grid()

    [
      {grid, submarine, :submarine},
      {grid, destroyer, :destroyer},
      {grid, cruiser, :cruiser},
      {grid, battleship, :battleship}
    ]
  end

  defp create_grid() do
    submarine1 = Battleship.Ship.new(Battleship.Square.new({1, 1}))
    submarine2 = Battleship.Ship.new(Battleship.Square.new({3, 1}))
    submarine3 = Battleship.Ship.new(Battleship.Square.new({5, 1}))
    submarine4 = Battleship.Ship.new(Battleship.Square.new({7, 1}))

    destroyer1 =
      Battleship.Ship.new(
        Battleship.Square.new({1, 3}),
        Battleship.Square.new({1, 4})
      )

    destroyer2 =
      Battleship.Ship.new(
        Battleship.Square.new({3, 3}),
        Battleship.Square.new({3, 4})
      )

    destroyer3 =
      Battleship.Ship.new(
        Battleship.Square.new({5, 3}),
        Battleship.Square.new({5, 4})
      )

    cruiser1 =
      Battleship.Ship.new(
        Battleship.Square.new({7, 3}),
        Battleship.Square.new({7, 4}),
        Battleship.Square.new({7, 5})
      )

    cruiser2 =
      Battleship.Ship.new(
        Battleship.Square.new({9, 3}),
        Battleship.Square.new({9, 4}),
        Battleship.Square.new({9, 5})
      )

    battleship1 =
      Battleship.Ship.new(
        Battleship.Square.new({1, 7}),
        Battleship.Square.new({1, 8}),
        Battleship.Square.new({1, 9}),
        Battleship.Square.new({1, 10})
      )

    Battleship.Grid.new()
    |> Battleship.Grid.add_ship(submarine1)
    |> Battleship.Grid.add_ship(submarine2)
    |> Battleship.Grid.add_ship(submarine3)
    |> Battleship.Grid.add_ship(submarine4)
    |> Battleship.Grid.add_ship(destroyer1)
    |> Battleship.Grid.add_ship(destroyer2)
    |> Battleship.Grid.add_ship(destroyer3)
    |> Battleship.Grid.add_ship(cruiser1)
    |> Battleship.Grid.add_ship(cruiser2)
    |> Battleship.Grid.add_ship(battleship1)
  end
end
