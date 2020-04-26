defmodule BattleshipWeb.GameChannel do
  use Phoenix.Channel

  def join("game:" <> _game_id, _message, socket) do
    {:ok, socket}
  end
end
