defmodule MyAppWeb.ControllerHelpers do
  alias Guardian.Plug, as: GuardianPlug

  def current_user(conn) do
    GuardianPlug.current_resource(conn)
  end
end
