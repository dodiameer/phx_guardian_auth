defmodule MyAppWeb.UserController do
  use MyAppWeb, :controller

  alias MyApp.Accounts
  alias MyApp.Accounts.User
  alias MyAppWeb.Auth.Guardian

  action_fallback MyAppWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params),
    {:ok, user, token, refresh_token} <- Guardian.create_token(user) do
      conn
      |> put_status(:created)
      |> render("user.json", user: user, token: token, refresh_token: refresh_token)
    end
  end

  def signin(conn, %{"email" => email, "password" => password}) do
    with {:ok, user, token, refresh_token} <- Guardian.authenticate(email, password) do
      conn
      |> put_status(:ok)
      |> render("user.json", user: user, token: token, refresh_token: refresh_token)
    end
  end

  def signout(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, claims} <- Guardian.decode_and_verify(refresh_token, %{"typ" => "refresh"}) do
      Guardian.revoke_refresh_token(refresh_token, claims)
      conn
      |> put_status(:ok)
      |> render("signout.json")
    end
  end

  def refresh(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, user, new_token, new_refresh_token} <- Guardian.exchange_refresh_to_pair(refresh_token) do
      conn
      |> put_status(:ok)
      |> render("user.json", user: user, token: new_token, refresh_token: new_refresh_token)
    end
  end
end
