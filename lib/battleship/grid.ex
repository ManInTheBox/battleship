defmodule Battleship.Grid do
  @size 1..10
  @ship_count %{submarine: 4, destroyer: 3, cruiser: 2, battleship: 1}

  def dimensions, do: @size
  def new, do: []

  def add_ship(grid, ship) do
    with {:ok} <- assert_all_ships_arranged(grid, ship),
         {:ok} <- assert_ship_overlap(grid, ship) do
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

  defp assert_all_ships_arranged(grid, ship) do
    type = ship_type(ship)
    ships = Enum.filter(grid, fn ship -> ship_type(ship) == type end)

    if length(ships) >= @ship_count[type] do
      {:error, :all_ships_arranged, type}
    else
      {:ok}
    end
  end

  defp assert_ship_overlap(grid, ship) do
    new_ship = Tuple.to_list(ship)

    already_exists =
      Enum.any?(grid, fn existing_ship ->
        Enum.any?(Tuple.to_list(existing_ship), fn square ->
          square in new_ship
        end)
      end)

    case already_exists do
      true ->
        {:error, :ships_overlap, ship}

      _ ->
        {:ok}
    end
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
