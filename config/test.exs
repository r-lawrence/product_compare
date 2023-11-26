import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :product_compare_web, ProductCompareWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "cCNnaJAdtzoQMr3rU4eowQXklm3IUreJI58saoa9IMbNbF8xMlK7gzkg88puYWae",
  server: false

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :product_database, ProductDatabase.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "product_database_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :product_database, ProductDatabase.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "product_database_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
# config :product_compare, ProductCompare.Repo,
#   username: "postgres",
#   password: "postgres",
#   hostname: "localhost",
#   database: "product_compare_test#{System.get_env("MIX_TEST_PARTITION")}",
#   pool: Ecto.Adapters.SQL.Sandbox,
#   pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :product_compare_web, ProductCompareWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "v1gdvN4OPtzyEnQj4GWeW+UsgqKQEVuMCxwoDXje8VyxVmI9L/0LmC9eIyz4yutw",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
