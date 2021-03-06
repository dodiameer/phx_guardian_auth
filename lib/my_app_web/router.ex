defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_cookies, signed: ~w(my_app_refresh_token)
  end

  pipeline :auth do
    plug MyAppWeb.Auth.Pipeline
  end

  scope "/api", MyAppWeb do
    pipe_through :api

    post "/users/signup", UserController, :create
    post "/users/signin", UserController, :signin
    post "/users/signout", UserController, :signout
    post "/users/refresh", UserController, :refresh

    scope "/" do
      pipe_through :auth

      # Put authorized-only routes here
      resources "/todos", TodoController, except: [:new, :edit]
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: MyAppWeb.Telemetry
    end
  end
end
