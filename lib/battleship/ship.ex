defmodule Battleship.Ship do
  def new(square), do: do_create([square])
  def new(square1, square2), do: do_create([square1, square2])
  def new(square1, square2, square3), do: do_create([square1, square2, square3])

  def new(square1, square2, square3, square4),
    do: do_create([square1, square2, square3, square4])

  defp do_create(squares) when is_list(squares) do
    case validate_squares(squares) do
      {:ok, squares} ->
        List.to_tuple(squares)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp validate_squares(squares) do
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
        {:ok, squares}
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
