# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :my_app,
  ecto_repos: [MyApp.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :my_app, MyAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lJvabTrYgI4pGJMGtwu6lKEANu2c74g9QzHNeWp243vNdAKAGgAadQEvTi8OtRHV",
  render_errors: [view: MyAppWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: MyApp.PubSub,
  live_view: [signing_salt: "9uQKxpGH"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :my_app, MyAppWeb.Auth.Guardian,
  issuer: "my_app",
  secret_key: System.get_env("JWT_SECRET", "Ta3t9KQJccM4hi6ejNRyUl8oypWhVTIEIYzJq/BzVtvJJaUy5t3q2FjAj1lslo9S"),
  ttl: {15, :minute},
  token_ttl: %{refresh: {7, :days}} # This doesn't work for some reason which is why it's also used in the function to generate it

config :guardian, Guardian.DB,
  repo: MyApp.Repo, # Add your repository module
  schema_name: "guardian_tokens", # default
  sweep_interval: 30  # 30 minutes


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
