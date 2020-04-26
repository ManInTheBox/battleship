defmodule Battleship.Game do
  use GenServer

  def create(id, players) do
    GenServer.start_link(__MODULE__, %{id: id, players: players}, name: via_tuple(id))
    id
  end

  def find_by_id(id) do
    case Registry.lookup(__MODULE__, id) do
      [] ->
        {:error, :not_found}

      [{game, _}] ->
        GenServer.call(via_tuple(id), :find_by_id)
    end
  end

  @impl true
  def init(game) do
    player1 = Enum.at(game.players, 0)
    player2 = Enum.at(game.players, 1)

    game = %{
      id: game.id,
      start_time: DateTime.utc_now(),
      player1: %{"id" => player1["id"], "my_grid" => player1["grid"], "opponent_grid" => []},
      player2: %{"id" => player2["id"], "my_grid" => player2["grid"], "opponent_grid" => []}
    }

    Battleship.GameSeek.remove(game.id)

    {:ok, game}
  end

  @impl true
  def handle_call(:find_by_id, _from, game) do
    {:reply, game, game}
  end

  defp via_tuple(key) do
    {:via, Registry, {__MODULE__, key}}
  end
end
