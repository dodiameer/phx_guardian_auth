defmodule MyAppWeb.UserView do
  use MyAppWeb, :view

  def render("user.json", %{user: user, token: token, refresh_token: refresh_token}) do
    %{data: %{email: user.email, token: token, refresh_token: refresh_token}}
  end

  def render("signout.json", _no_params) do
    %{data: %{success: true}}
  end
end
