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

    other_user = get_in(game, [get_other_player(player), "id"])

    case Battleship.Grid.fire_torpedo(opponent_grid, square) do
      {:water, {{x, y}, :water} = torpedo, opponent_grid} ->
        game
        |> update_in([player, "opponent_grid"], &[{torpedo} | &1])
        |> update_in([get_other_player(player), "my_grid"], fn _ -> opponent_grid end)
        |> update_in([:player_to_shoot], fn _ -> other_user end)
        |> Battleship.Game.update()

        broadcast!(socket, "fire_torpedo_water", %{
          "square" => "#{x}-#{y}",
          "user" => user,
          "other_user" => other_user
        })

      {:hit, {{x, y}, :hit} = torpedo, opponent_grid} ->
        game
        |> update_in([player, "opponent_grid"], &[{torpedo} | &1])
        |> update_in([get_other_player(player), "my_grid"], fn _ -> opponent_grid end)
        |> Battleship.Game.update()

        broadcast!(socket, "fire_torpedo_hit", %{
          "square" => "#{x}-#{y}",
          "user" => user,
          "other_user" => other_user
        })

      {:sunk, ship, opponent_grid} ->
        game =
          game
          |> update_in([player, "opponent_grid"], &[ship | &1])
          |> update_in([get_other_player(player), "my_grid"], fn _ -> opponent_grid end)

        Battleship.Game.update(game)

        squares =
          ship
          |> Tuple.to_list()
          |> Enum.map(fn {square, state} ->
            [Enum.join(Tuple.to_list(square), "-"), state]
          end)
          |> Jason.encode!()

        water_squares =
          ship
          |> Tuple.to_list()
          |> Enum.map(fn {{x, y}, _state} ->
            water_next_to_me? = fn {x1, y1} ->
              !Enum.any?(Tuple.to_list(ship), fn {{x2, y2}, _state} ->
                x1 == x2 && y1 == y2
              end)
            end

            s = []

            s =
              if water_next_to_me?.({x + 1, y}),
                do:
                  [{{x + 1, y}, :water}, {{x + 1, y - 1}, :water}, {{x + 1, y + 1}, :water}] ++ s,
                else: s

            s =
              if water_next_to_me?.({x - 1, y}),
                do:
                  [{{x - 1, y}, :water}, {{x - 1, y - 1}, :water}, {{x - 1, y + 1}, :water}] ++ s,
                else: s

            s =
              if water_next_to_me?.({x, y - 1}),
                do:
                  [{{x, y - 1}, :water}, {{x - 1, y - 1}, :water}, {{x + 1, y - 1}, :water}] ++ s,
                else: s

            s =
              if water_next_to_me?.({x, y + 1}),
                do:
                  [{{x, y + 1}, :water}, {{x - 1, y + 1}, :water}, {{x + 1, y + 1}, :water}] ++ s,
                else: s
          end)
          |> List.flatten()
          |> Enum.uniq()

        game
        |> update_in([player, "opponent_grid"], fn opponent_grid ->
          Enum.map(water_squares, &{&1}) ++ opponent_grid
        end)
        |> Battleship.Game.update()

        water_squares =
          water_squares
          |> Enum.map(fn {square, state} = torpedo ->
            [Enum.join(Tuple.to_list(square), "-"), state]
          end)
          |> Jason.encode!()

        broadcast!(socket, "fire_torpedo_sunk", %{
          "squares" => squares,
          "water_squares" => water_squares,
          "user" => user,
          "other_user" => other_user
        })

      any ->
        IO.inspect(any, label: "ovo je any")
    end

    {:noreply, socket}
  end

  defp get_other_player(player) do
    if player == :player1, do: :player2, else: :player1
  end
end
