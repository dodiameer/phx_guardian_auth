defmodule MyAppWeb.Auth.Guardian do
  use Guardian, otp_app: :my_app

  alias MyApp.Accounts

  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    resource = Accounts.get_user!(id)
    {:ok, resource}
  end

  def authenticate(email, password) do
    with {:ok, user} <- Accounts.get_by_email(email) do
      case validate_password(password, user.encrypted_password) do
        true ->
          create_token(user)
        false ->
          {:error, :unauthorized}
      end
    end
  end

  defp validate_password(password, encrypted_password) do
    ComeonIn.Pbkdf2.checkpw(password, encrypted_password)
  end

  def create_token(user) do
    {:ok, token, _claims} = encode_and_sign(user, %{})
    {:ok, _user, refresh_token} = create_refresh_token(user, token)
    {:ok, user, token, refresh_token}
  end

  defp create_refresh_token(user, access_token) do
    {:ok, refresh_token, _claims} = encode_and_sign(user, %{access_token: access_token}, token_type: "refresh", ttl: {7, :days})
    {:ok, user, refresh_token}
  end

  def exchange_refresh_to_pair(old_refresh_token) do
    with {:ok, claims} <- decode_and_verify(old_refresh_token, %{"typ" => "refresh"}) do
      {:ok} = revoke_refresh_token(old_refresh_token, claims)
      {:ok, user} = resource_from_claims(claims)
      {:ok, _user, access_token, refresh_token} = create_token(user)
      {:ok, user, access_token, refresh_token}
    end
  end

  def revoke_refresh_token(token, claims) do
    revoke(token)
    revoke(claims["access_token"])
    {:ok}
  end

  def after_encode_and_sign(resource, claims, token, _options) do
    with {:ok, _} <- Guardian.DB.after_encode_and_sign(resource, claims["typ"], claims, token) do
      {:ok, token}
    end
  end

  def on_verify(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_verify(claims, token) do
      {:ok, claims}
    end
  end

  def on_refresh({old_token, old_claims}, {new_token, new_claims}, _options) do
    with {:ok, _, _} <- Guardian.DB.on_refresh({old_token, old_claims}, {new_token, new_claims}) do
      {:ok, {old_token, old_claims}, {new_token, new_claims}}
    end
  end

  def on_revoke(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_revoke(claims, token) do
      {:ok, claims}
    end
  end
end
