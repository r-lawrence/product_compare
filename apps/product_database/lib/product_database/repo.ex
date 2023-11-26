defmodule ProductDatabase.Repo do
  use Ecto.Repo,
    otp_app: :product_database,
    adapter: Ecto.Adapters.Postgres
end
