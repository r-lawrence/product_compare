defmodule ProductDatabase.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ProductDatabase.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ProductDatabase.PubSub}
      # Start a worker by calling: ProductDatabase.Worker.start_link(arg)
      # {ProductDatabase.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: ProductDatabase.Supervisor)
  end
end
