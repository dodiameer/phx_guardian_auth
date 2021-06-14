defmodule MyAppWeb.Auth.ErrorHandler do
  import Plug.Conn

  def auth_error(conn, {:invalid_token, _reason}, _opts) do
    send_err(conn, "Invalid token")
  end

  def auth_error(conn, {type, _reason}, _opts) do
    send_err(conn, to_string(type))
  end

  defp send_err(conn, error) do
    body = Jason.encode!(%{error: error})
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, body)
  end
end
