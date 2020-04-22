defmodule Battleship.GameSeek do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def find_matching_seek(user) do
    Agent.get(__MODULE__, fn seeks ->
      Enum.find(seeks, fn %{from: from} -> from != user end)
    end)
  end

  def create(user, grid) do
    id = UUID.uuid4()
    Agent.update(__MODULE__, fn seeks ->
      seek = %{id: id, from: user, grid: grid}
      [seek | seeks]
    end)
    id
  end

  def get_grid(id, user) do
    %{grid: grid} =
      Agent.get(__MODULE__, fn seeks ->
        Enum.find(seeks, fn %{id: id, from: user} -> true end)
      end)
    grid
  end
end

# [
#   %{id: "1234-456", from: "zarko", grid: [{{{1, 1}, :active}, {{1, 2}, :active}}]},
#   %{id: "789-01234", from: "aleksandra", grid: [{{{5, 5}, :active}, {{5, 6}, :active}}]}
# ]
