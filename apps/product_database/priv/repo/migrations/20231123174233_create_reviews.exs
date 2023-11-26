defmodule ProductDatabase.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def change do
    create table(:reviews, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :reviews, {:array, :text}
      add :summary, :map
      add :product_id, references(:products, type: :uuid, on_delete: :delete_all)

      timestamps()
    end

    create index(:reviews, [:product_id])
  end
end
