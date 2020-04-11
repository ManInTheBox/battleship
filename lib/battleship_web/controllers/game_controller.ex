defmodule BattleshipWeb.GameController do
  use BattleshipWeb, :controller
  require Logger

  def index(conn, _params) do
    render(conn, "index.html", token: get_csrf_token())
  end

  def create(conn, params) do
    squares = create_squares(params["ships"])
    ships = create_ships(squares)

    render(conn, "index.html", token: get_csrf_token())
  end

  def show(conn, %{"id" => id} = _params) do
    render(conn, "show.html", id: id)
  end

  defp create_squares(ships) do
    Enum.map(String.split(ships), fn square ->
      [x, y] = String.split(square, "-")
      Battleship.Square.new({String.to_integer(x), String.to_integer(y)})
    end)
    |> Enum.sort()
  end

  defp create_ships(squares) do
    squares
    |> Enum.reduce([], &create_ship/2)
    |> Enum.reverse()
    |> Enum.map(fn ship ->
      ship
      |> Enum.reverse()
      |> List.to_tuple()
    end)
  end

  defp create_ship(square, []), do: [[square]]
  defp create_ship({x2, y2} = square, acc) do
    [ship | tail] = acc
    {x1, y1} = hd(ship)

    is_sibling = (x1 + 1 === x2 and y1 === y2) or (y1 + 1 === y2 and x1 === x2)

    if is_sibling do
      ship = [square | ship]
      [ship | tail]
    else
      [[square] | acc]
    end
  end
end
