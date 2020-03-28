defmodule Battleship.Piece do
  def new(square), do: do_create([square])
  def new(square1, square2), do: do_create([square1, square2])
  def new(square1, square2, square3), do: do_create([square1, square2, square3])
  def new(square1, square2, square3, square4), do: do_create([square1, square2, square3, square4])

  def name(_), do: "Submarine"
  def name(_, _), do: "Destroyer"
  def name(_, _, _), do: "Cruiser"
  def name(_, _, _, _), do: "Battleship"

  defp do_create(squares) when is_list(squares) do
    squares =
      squares
      |> Enum.map(fn square -> Battleship.Square.new(square) end)
      |> Enum.sort()

    cond do
      !unique_squares?(squares) ->
        {:error, :not_unique_squares}

      !are_siblings?(squares) ->
        {:error, :not_siblings}

      true ->
        squares
    end
  end

  defp unique_squares?(squares) do
    Enum.uniq(squares) === squares
  end

  defp are_siblings?(squares) do
    last =
      Enum.reduce(squares, fn {x2, y2} = second, {x1, y1} = first ->
        cond do
          x1 + 1 === x2 and y1 === y2 ->
            second

          y1 + 1 === y2 and x1 === x2 ->
            second

          true ->
            first
        end
      end)

    List.last(squares) === last
  end
end
