defmodule Battleship.Ship do
  defstruct squares: nil, type: nil

  def new(square), do: do_create([square], :submarine)
  def new(square1, square2), do: do_create([square1, square2], :destroyer)
  def new(square1, square2, square3), do: do_create([square1, square2, square3], :cruiser)

  def new(square1, square2, square3, square4),
    do: do_create([square1, square2, square3, square4], :battleship)

  defp do_create(squares, type) when is_list(squares) and is_atom(type) do
    case validate_squares(squares) do
      {:ok, squares} ->
        %Battleship.Ship{squares: List.to_tuple(squares), type: type}

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
