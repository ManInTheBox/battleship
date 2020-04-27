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
    user = conn.req_cookies["user_id"]

    grid =
      params["ships"]
      |> create_squares()
      |> create_ships()
      |> create_grid()

    case Battleship.GameSeek.find_matching_seek(user) do
      nil ->
        id = Battleship.GameSeek.create(user, grid)
        redirect(conn, to: Routes.game_path(conn, :show, id))

      %{id: id, from: opponent_user, grid: opponent_grid} ->
        players = [
          %{"id" => user, "grid" => grid},
          %{"id" => opponent_user, "grid" => opponent_grid}
        ]

        Battleship.Game.create(id, players)
        game = Battleship.Game.find_by_id(id)

        BattleshipWeb.Endpoint.broadcast("game:#{id}", "game_started", %{
          "message" => "The game has just started.",
          "is_my_turn" => game[:player_to_shoot] != conn.req_cookies["user_id"]
        })

        conn = put_flash(conn, :success, "The game has just started.")

        redirect(conn, to: Routes.game_path(conn, :show, id))
    end
  end

  def show(conn, %{"id" => id} = _params) do
    case get_grids(id, conn.req_cookies["user_id"]) do
      {:error, :not_found} ->
        conn = put_flash(conn, :error, "This game does not exist.")
        redirect(conn, to: Routes.game_path(conn, :index))

      {status, my_grid, opponent_grid, nil} ->
        my_squares =
          my_grid
          |> Enum.map(fn ship ->
            Enum.map(Tuple.to_list(ship), fn {square, state} ->
              [Enum.join(Tuple.to_list(square), "-"), state]
            end)
          end)
          |> Enum.concat()
          |> Jason.encode!()

        opponent_squares =
          opponent_grid
          |> Enum.map(fn ship ->
            Enum.map(Tuple.to_list(ship), fn {square, state} ->
              [Enum.join(Tuple.to_list(square), "-"), state]
            end)
          end)
          |> Enum.concat()
          |> Jason.encode!()

        render(conn, "show.html",
          my_squares: my_squares,
          opponent_squares: opponent_squares,
          status: status,
          is_my_turn: false
        )

      {status, my_grid, opponent_grid, game} ->
        my_squares =
          my_grid
          |> Enum.map(fn ship ->
            Enum.map(Tuple.to_list(ship), fn {square, state} ->
              [Enum.join(Tuple.to_list(square), "-"), state]
            end)
          end)
          |> Enum.concat()
          |> Jason.encode!()

        opponent_squares =
          opponent_grid
          |> Enum.map(fn ship ->
            Enum.map(Tuple.to_list(ship), fn {square, state} ->
              [Enum.join(Tuple.to_list(square), "-"), state]
            end)
          end)
          |> Enum.concat()
          |> Jason.encode!()

        render(conn, "show.html",
          my_squares: my_squares,
          opponent_squares: opponent_squares,
          status: status,
          is_my_turn: game[:player_to_shoot] == conn.req_cookies["user_id"]
        )
    end
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

  defp get_grids(id, user) do
    case Battleship.Game.find_by_id(id) do
      {:error, :not_found} ->
        game_seek = Battleship.GameSeek.find_by_id_and_user(id, user)

        if game_seek == nil do
          {:error, :not_found}
        else
          my_grid = game_seek.grid
          opponent_grid = Battleship.Grid.new()
          {:waiting_for_opponent, my_grid, opponent_grid, nil}
        end

      game ->
        if get_in(game, [:player1, "id"]) == user do
          my_grid = get_in(game, [:player1, "my_grid"])
          opponent_grid = get_in(game, [:player1, "opponent_grid"])
          {:ready, my_grid, opponent_grid, game}
        else
          my_grid = get_in(game, [:player2, "my_grid"])
          opponent_grid = get_in(game, [:player2, "opponent_grid"])
          {:ready, my_grid, opponent_grid, game}
        end
    end
  end
end
