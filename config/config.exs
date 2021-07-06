# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bebemayotte,
  ecto_repos: [Bebemayotte.Repo]

  config :phoenix,
    template_engines: [leex: Phoenix.LiveView.Engine]
# Configures the endpoint
config :bebemayotte, BebemayotteWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "w2OJ0kInCK+f7766/jEbrPb7EQLpAc4BsZ2Voqm7lNBbm+MwCd7OgqN6Vu4HXu+i",
  render_errors: [view: BebemayotteWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Bebemayotte.PubSub,
  live_view: [signing_salt: "ndzum7Su"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason
config :phoenix, template_engines: [leex: Phoenix.LiveView.Engine]
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
