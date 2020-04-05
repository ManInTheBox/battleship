defmodule Battleship.Grid do
  @size 1..10
  @ship_count %{submarine: 4, destroyer: 3, cruiser: 2, battleship: 1}

  def dimensions, do: @size
  def new, do: []

  def add_ship(grid, ship) do
    with {:ok} <- assert_all_ships_arranged(grid, ship) do
      [ship | grid]
    end
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
