defmodule Battleship.Piece do
  def new(field), do: do_create([field])
  def new(field1, field2), do: do_create([field1, field2])
  def new(field1, field2, field3), do: do_create([field1, field2, field3])
  def new(field1, field2, field3, field4), do: do_create([field1, field2, field3, field4])

  def name(_), do: "Submarine"
  def name(_, _), do: "Destroyer"
  def name(_, _, _), do: "Cruiser"
  def name(_, _, _, _), do: "Battleship"

  defp do_create(fields) when is_list(fields) do
    fields =
      fields
      |> Enum.map(fn field -> Battleship.Field.new(field) end)
      |> Enum.sort()

    cond do
      !unique_fields?(fields) ->
        {:error, :not_unique_fields}

      !are_siblings?(fields) ->
        {:error, :not_siblings}

      true ->
        fields
    end
  end

  defp unique_fields?(fields) do
    Enum.uniq(fields) === fields
  end

  defp are_siblings?(fields) do
    last =
      Enum.reduce(fields, fn {x2, y2} = second, {x1, y1} = first ->
        cond do
          x1 + 1 === x2 and y1 === y2 ->
            second

          y1 + 1 === y2 and x1 === x2 ->
            second

          true ->
            first
        end
      end)

    List.last(fields) === last
  end
end
