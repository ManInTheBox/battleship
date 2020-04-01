defmodule Battleship.Grid do
  @size 1..10

  def dimensions, do: @size

  def new() do
    %{
      allowed_ships: %{submarine: 4, destroyer: 3, cruiser: 2, battleship: 1},
      occupied: []
    }
  end

  def add_ship(grid, {square1}) do
    with {:ok, allowed_ships} <- decrement_allowed_ships(grid.allowed_ships, :submarine),
         {:ok, occupied} <- occupy_squares(grid.occupied, square1) do
      %{allowed_ships: allowed_ships, occupied: occupied}
    end
  end

  defp decrement_allowed_ships(allowed_ships, type) do
    if allowed_ships[type] === 0 do
      {:error, :all_ships_arranged, type}
    else
      allowed_ships = Map.update!(allowed_ships, type, fn current -> current - 1 end)
      {:ok, allowed_ships}
    end
  end

  defp occupy_squares(occupied, square1) do
    occupied = [square1 | occupied]
    occupied = Enum.sort(occupied)
    {:ok, occupied}
  end
end
