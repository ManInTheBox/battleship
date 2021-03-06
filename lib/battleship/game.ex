defmodule Battleship.Game do
  use GenServer

  defstruct id: nil,
            player_1: nil,
            player_2: nil,
            player_to_shoot: nil,
            start_time: DateTime.utc_now(),
            available_ships: Battleship.Grid.ship_count

  def create(id, players) do
    GenServer.start_link(__MODULE__, %{id: id, players: players}, name: via_tuple(id))
    id
  end

  def find_by_id(id) do
    case Registry.lookup(__MODULE__, id) do
      [] ->
        {:error, :not_found}

      [{_game, _}] ->
        GenServer.call(via_tuple(id), :find_by_id)
    end
  end

  def update(game) do
    GenServer.cast(via_tuple(game.id), {:update, game})
  end

  def sunk(game, ship) do
    GenServer.cast(via_tuple(game.id), {:sunk, ship})
  end

  def game_over?(game) do
    Enum.all?(game.available_ships, fn {type, remaining} -> remaining == 0 end)
  end

  @impl true
  def init(game) do
    player1 = Enum.at(game.players, 0)
    player2 = Enum.at(game.players, 1)

    game = %Battleship.Game{
      id: game.id,
      player_1: %{"id" => player1["id"], "my_grid" => player1["grid"], "opponent_grid" => []},
      player_2: %{"id" => player2["id"], "my_grid" => player2["grid"], "opponent_grid" => []},
      player_to_shoot: Enum.random([player1["id"], player2["id"]])
    }

    Battleship.GameSeek.remove(game.id)

    {:ok, game}
  end

  @impl true
  def handle_call(:find_by_id, _from, game) do
    {:reply, game, game}
  end

  @impl true
  def handle_cast({:update, new_game}, _game) do
    {:noreply, new_game}
  end

  @impl true
  def handle_cast({:sunk, ship}, game) do
    available_ships = Map.update!(game.available_ships, Battleship.Grid.ship_type(ship), &(&1 - 1))
    {:noreply, %{game | available_ships: available_ships}}
  end

  defp via_tuple(key) do
    {:via, Registry, {__MODULE__, key}}
  end
end
