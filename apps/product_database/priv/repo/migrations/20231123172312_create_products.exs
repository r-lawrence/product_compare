defmodule ProductDatabase.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :sku, :string
      add :image, :text
      add :price, :string
      add :name, :text
      add :features, {:array, :text}

      timestamps()
    end

    create index(:products, [:sku], unique: true)
  end
end
