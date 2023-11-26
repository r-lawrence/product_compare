defmodule ProductDatabase.Repo.Migrations.CreateGptComparisons do
  use Ecto.Migration
  # can pontentiall use the skus to make a hash and add as an index
  # when querying this table, i can get hash from skus and attempt to look up record that way
  # for now since this is mvp, were just going to leave as is.
  def change do
    create table(:gpt_comparisons, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :product_skus, {:array, :string}
      add :comparison_result, :map

      timestamps()
    end

  end
end
