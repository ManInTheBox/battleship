defmodule BattleshipWeb.GameController do
  use BattleshipWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", token: get_csrf_token())
  end

  def create(conn, params) do
    squares =
      Enum.map(String.split(params["ships"]), fn square ->
        [x, y] = String.split(square, "-")
        Battleship.Square.new({String.to_integer(x), String.to_integer(y)})
      end)
      |> Enum.sort()

    render(conn, "index.html", token: get_csrf_token())
  end

  def show(conn, %{"id" => id} = params) do
    render(conn, "show.html", id: id)
  end
end
