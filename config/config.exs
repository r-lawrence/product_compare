
# Configure Mix tasks and generators
# config :product_compare,
#   ecto_repos: [ProductCompare.Repo]
# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config


# Configure Mix tasks and generators
config :product_database,
  ecto_repos: [ProductDatabase.Repo]


config :engine,
  ecto_repos: [ProductDatabase.Repo],
  pubsub_server: ProductDatabase.PubSub

config :product_compare_web,
  ecto_repos: [ProductDatabase.Repo],
  generators: [context_app: :product_database]

# Configures the endpoint
config :product_compare_web, ProductCompareWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: ProductCompareWeb.ErrorHTML, json: ProductCompareWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ProductDatabase.PubSub,
  live_view: [signing_salt: "MKDVAnw9"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/product_compare_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../apps/product_compare_web/assets", __DIR__)
  ]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :product_database, ProductDatabase.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false


# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

config :hound, driver: "chrome_driver"

config :engine, :gpt_api_key, System.get_env("GPT_API_KEY")

import_config "#{config_env()}.exs"
