defmodule Battleship.Game do
  use GenServer

  @id "abc-def"

  def create(grid) do
    GenServer.start_link(__MODULE__, grid, name: via_tuple(@id))
    @id
  end

  def get_grid(id) do
    GenServer.call(via_tuple(id), :get_grid)
  end

  @impl true
  def init(grid) do
    {:ok, %{"my_grid" => grid}}
  end

  @impl true
  def handle_call(:get_grid, _from, state) do
    {:reply, state, state}
  end

  defp via_tuple(key) do
    {:via, Registry, {Battleship.GamePool, key}}
  end
end
