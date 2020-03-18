defmodule BattleshipWeb.GameController do
  use BattleshipWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show(conn, %{"id" => id} = params) do
    render(conn, "show.html", id: id)
  end
end
