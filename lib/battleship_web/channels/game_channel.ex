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

    {player, opponent_grid, my_shooting_grid} =
      if game[:player1]["id"] == user do
        {:player1, game[:player2]["my_grid"], game[:player1]["opponent_grid"]}
      else
        {:player2, game[:player1]["my_grid"], game[:player2]["opponent_grid"]}
      end

    case Battleship.Grid.fire_torpedo(opponent_grid, square) do
      {:water, {{x, y}, :water} = shoot, opponent_grid} ->
        other_user = get_in(game, [get_other_player(player), "id"])

        game
        |> update_in([player, "opponent_grid"], &[{shoot} | &1])
        |> update_in([get_other_player(player), "my_grid"], &[{shoot} | &1])
        |> update_in([:player_to_shoot], fn _ -> other_user end)
        |> Battleship.Game.update()

        broadcast!(socket, "fire_torpedo_water", %{
          "square" => "#{x}-#{y}",
          "user" => user,
          "other_user" => other_user
        })

      {:hit, {{x, y}, :hit}, opponent_grid} ->
        IO.inspect(opponent_grid, label: "Hit")
        broadcast!(socket, "fire_torpedo_hit", %{"square" => "#{x}-#{y}", "user" => user})

      {:sunk, ship, opponent_grid} ->
        IO.inspect(ship, label: "Sunk")

      any ->
        IO.inspect(any, label: "ovo je any")
    end

    {:noreply, socket}
  end

  defp get_other_player(player) do
    if player == :player1, do: :player2, else: :player1
  end
end
