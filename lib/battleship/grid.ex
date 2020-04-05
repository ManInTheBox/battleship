defmodule Battleship.Grid do
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
    already_exists = assert_ship_position(grid, ship, fn square, new_ship ->
      square in new_ship
    end)

    if already_exists do
      {:error, :ships_overlap, ship}
    else
      {:ok}
    end
  end

  defp assert_ships_not_touching(grid, ship) do
    new_ship = Tuple.to_list(ship)

    is_touching =
      Enum.any?(grid, fn existing_ship ->
        Enum.any?(Tuple.to_list(existing_ship), fn square ->
          square = elem(square, 0)
          {x, y} = square

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
end
