defmodule Battleship.Grid do
  require Logger
  @size 1..10
  @ship_count %{submarine: 4, destroyer: 3, cruiser: 2, battleship: 1}

  def dimensions, do: @size
  def new, do: []

  def add_ship(grid, ship) do
    with {:ok} <- assert_ships_not_arranged(grid, ship),
         {:ok} <- assert_ships_not_overlap(grid, ship),
         {:ok} <- assert_ships_not_touching(grid, ship) do
      do_add_ship(grid, ship)
    end
  end

  # {:water, {{1, 2}, :water}, grid}
  # {:hit, {{1, 3}, :hit}, grid}
  # {:hit, {{1, 4}, :hit}, grid}
  # {:sunk, {{{1, 3}, :sunk}, {{1, 4}, :sunk}, {{1, 5}, :sunk}}, grid}
  def fire_torpedo(grid, square) do
    ship =
      Enum.find(grid, fn ship ->
        Enum.find(Tuple.to_list(ship), fn {s, state} ->
          square == s && state == :alive
        end)
      end)

    case ship do
      nil -> torpedo_miss(grid, square)
      _ -> torpedo_hit(grid, ship, square)
    end
  end

  defp do_add_ship(grid, ship) do
    ship =
      ship
      |> Tuple.to_list()
      |> Enum.map(fn square -> {square, :alive} end)
      |> List.to_tuple()

    [ship | grid]
  end

  defp assert_ships_not_arranged(grid, ship) do
    type = ship_type(ship)
    ships = Enum.filter(grid, fn ship -> ship_type(ship) == type end)

    if length(ships) >= @ship_count[type] do
      {:error, :ships_arranged, type}
    else
      {:ok}
    end
  end

  defp assert_ships_not_overlap(grid, ship) do
    already_exists =
      assert_ship_position(grid, ship, fn square, new_ship ->
        square in new_ship
      end)

    if already_exists do
      {:error, :ships_overlap, ship}
    else
      {:ok}
    end
  end

  defp assert_ships_not_touching(grid, ship) do
    is_touching =
      assert_ship_position(grid, ship, fn {x, y}, new_ship ->
        not_allowed_squares = [
          {x + 1, y},
          {x - 1, y},
          {x, y + 1},
          {x, y - 1},
          {x + 1, y + 1},
          {x + 1, y - 1},
          {x - 1, y + 1},
          {x - 1, y - 1}
        ]

        Enum.any?(new_ship, fn new_square -> new_square in not_allowed_squares end)
      end)

    if is_touching do
      {:error, :ships_touching_each_other, ship}
    else
      {:ok}
    end
  end

  defp assert_ship_position(grid, ship, fun) do
    new_ship = Tuple.to_list(ship)

    Enum.any?(grid, fn existing_ship ->
      Enum.any?(Tuple.to_list(existing_ship), fn square ->
        fun.(elem(square, 0), new_ship)
      end)
    end)
  end

  defp ship_type(ship) when is_tuple(ship) do
    case tuple_size(ship) do
      1 ->
        :submarine

      2 ->
        :destroyer

      3 ->
        :cruiser

      4 ->
        :battleship

      _ ->
        {:error, :unknown_ship_type}
    end
  end

  defp torpedo_miss(grid, square) do
    {:water, {square, :water}, grid}
  end

  defp torpedo_hit(grid, ship, square) do
    ship =
      ship
      |> Tuple.to_list()
      |> Enum.map(fn {s, state} ->
        if s == square do
          {s, :hit}
        else
          {s, state}
        end
      end)

    if Enum.all?(ship, fn {_, state} -> state == :hit end) do
      ship = Enum.map(ship, fn {s, _} -> {s, :sunk} end)
      {:sunk, List.to_tuple(ship), update_grid(grid, ship, square)}
    else
      {:hit, {square, :hit}, update_grid(grid, ship, square)}
    end
  end

  defp update_grid(grid, ship, square) do
    Enum.map(grid, fn sh ->
      if Enum.any?(Tuple.to_list(sh), fn {s, _} -> s == square end) do
        List.to_tuple(ship)
      else
        sh
      end
    end)
  end
end
