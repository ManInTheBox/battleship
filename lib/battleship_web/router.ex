defmodule BattleshipWeb.Router do
  use BattleshipWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BattleshipWeb do
    pipe_through :browser

    get "/", GameController, :index
    post "/", GameController, :create
    get "/game/:id", GameController, :show
  end

  if Mix.env() == :dev do
    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard"
    end
  end
end
