defmodule Battleship.GameSeek do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def create(user, grid) do
    id = UUID.uuid4()

    Agent.update(__MODULE__, fn seeks ->
      seek = %{id: id, from: user, grid: grid}
      [seek | seeks]
    end)

    id
  end

  def remove(id) do
    Agent.update(__MODULE__, fn seeks ->
      Enum.filter(seeks, fn seek -> seek.id != id end)
    end)
  end

  def find_matching_seek(user) do
    Agent.get(__MODULE__, fn seeks ->
      Enum.find(seeks, fn %{from: from} -> from != user end)
    end)
  end

  def find_by_id_and_user(id, user) do
    Agent.get(__MODULE__, fn seeks ->
      Enum.find(seeks, fn %{id: id, from: user} -> true end)
    end)
  end
end
