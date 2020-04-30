defmodule BattleshipWeb.GameChannel do
  use Phoenix.Channel

  def join("game:" <> _game_id, _message, socket) do
    {:ok, socket}
  end

  def handle_in(
        "fire_torpedo",
        %{"user" => user, "game_id" => game_id, "square" => square},
        socket
      ) do
    [x, y] = String.split(square, "-")
    square = Battleship.Square.new({String.to_integer(x), String.to_integer(y)})

    game = Battleship.Game.find_by_id(game_id)

    {grid, opponent_grid} =
      if game[:player1]["id"] == user do
        {game[:player2]["my_grid"], game[:player1]["opponent_grid"]}
      else
        {game[:player1]["my_grid"], game[:player2]["opponent_grid"]}
      end

    case Battleship.Grid.fire_torpedo(grid, square) do
      {:water, {{x, y}, :water}, grid} ->
        broadcast!(socket, "fire_torpedo_water", %{"square" => "#{x}-#{y}", "user" => user})

      {:hit, {{x, y}, :hit}, grid} ->
        IO.inspect(grid, label: "Hit")
        broadcast!(socket, "fire_torpedo_hit", %{"square" => "#{x}-#{y}", "user" => user})

      {:sunk, ship, grid} ->
        IO.inspect(ship, label: "Sunk")

      any ->
        IO.inspect(any, label: "ovo je any")
    end

    {:noreply, socket}
  end
end
