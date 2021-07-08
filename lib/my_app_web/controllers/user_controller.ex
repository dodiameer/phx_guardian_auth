defmodule MyAppWeb.UserController do
  use MyAppWeb, :controller

  alias MyApp.Accounts
  alias MyApp.Accounts.User
  alias MyAppWeb.Auth.Guardian

  action_fallback MyAppWeb.FallbackController

  defp put_refresh_token(conn, refresh_token) do
    conn
    |> put_resp_cookie("my_app_refresh_token", refresh_token, signed: true, max_age: 60 * 60 * 24 * 7)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params),
    {:ok, user, token, refresh_token} <- Guardian.create_token(user) do
      conn
      |> put_status(:created)
      |> put_refresh_token(refresh_token)
      |> render("user.json", user: user, token: token)
    end
  end

  def signin(conn, %{"email" => email, "password" => password}) do
    with {:ok, user, token, refresh_token} <- Guardian.authenticate(email, password) do
      conn
      |> put_status(:ok)
      |> put_refresh_token(refresh_token)
      |> render("user.json", user: user, token: token)
    end
  end

  def signout(conn, _) do
    refresh_token = conn.req_cookies["my_app_refresh_token"]
    with {:ok, _} <- Guardian.decode_and_verify(refresh_token, %{"typ" => "refresh"}) do
      Guardian.revoke_refresh_token(refresh_token)
      conn
      |> put_status(:ok)
      |> put_refresh_token("")
      |> render("signout.json")
    end
  end

  def refresh(conn, _) do
    refresh_token = conn.req_cookies["my_app_refresh_token"]
    case Guardian.exchange_refresh_to_pair(refresh_token) do
      {:ok, user, new_token, new_refresh_token} ->
        conn
        |> put_status(:ok)
        |> put_refresh_token(new_refresh_token)
        |> render("user.json", user: user, token: new_token)
      {:error, reason} ->
        {:error, reason}
    end
  end
end
