defmodule BattleshipWeb.GameController do
  use BattleshipWeb, :controller
  require Logger

  def index(conn, _params) do
    user_id =
      if conn.req_cookies["user_id"] == nil do
        UUID.uuid4()
      else
        conn.req_cookies["user_id"]
      end

    conn = Plug.Conn.put_resp_cookie(conn, "user_id", user_id)

    render(conn, "index.html")
  end

  def create(conn, params) do
    grid =
      params["ships"]
      |> create_squares()
      |> create_ships()
      |> create_grid()

    id = Battleship.Game.create(grid)

    redirect(conn, to: Routes.game_path(conn, :show, id))
  end

  def show(conn, %{"id" => id} = _params) do
    squares =
      id
      |> Battleship.Game.get_grid()
      |> Enum.map(fn ship ->
        Enum.map(Tuple.to_list(ship), fn {square, state} ->
          [Enum.join(Tuple.to_list(square), "-"), state]
        end)
      end)
      |> Enum.concat()
      |> Jason.encode!()

    render(conn, "show.html", squares: squares)
  end

  defp create_squares(ships) do
    ships
    |> String.split()
    |> Enum.map(fn square ->
      [x, y] = String.split(square, "-")
      Battleship.Square.new({String.to_integer(x), String.to_integer(y)})
    end)
  end

  defp create_ships(squares) do
    squares
    |> Enum.reduce([], &create_ship/2)
    |> Enum.reverse()
    |> Enum.map(fn ship ->
      case ship do
        [square1] ->
          Battleship.Ship.new(square1)

        [square1, square2] ->
          Battleship.Ship.new(square1, square2)

        [square1, square2, square3] ->
          Battleship.Ship.new(square1, square2, square3)

        [square1, square2, square3, square4] ->
          Battleship.Ship.new(square1, square2, square3, square4)

        _ ->
          {:error, :unknown_ship_type, ship}
      end
    end)
  end

  defp create_ship(square, []), do: [[square]]

  defp create_ship({x2, y2} = square, acc) do
    [ship | tail] = acc
    {x1, y1} = hd(ship)

    is_sibling =
      ((x1 + 1 === x2 or x1 - 1 === x2) and y1 === y2) or
        ((y1 + 1 === y2 or y1 - 1 === y2) and x1 === x2)

    if is_sibling do
      ship = [square | ship]
      [ship | tail]
    else
      [[square] | acc]
    end
  end

  defp create_grid(ships) do
    for ship <- ships, reduce: Battleship.Grid.new() do
      grid -> Battleship.Grid.add_ship(grid, ship)
    end
  end
end
