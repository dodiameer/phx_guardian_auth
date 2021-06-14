defmodule MyAppWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline, otp_app: :my_app,
    module: MyAppWeb.Auth.Guardian,
    error_handler: MyAppWeb.Auth.ErrorHandler

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource
end
