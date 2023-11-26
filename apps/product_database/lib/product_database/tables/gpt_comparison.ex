defmodule ProductDatabase.Tables.GptComparison do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "gpt_comparisons" do
    field :product_skus, {:array, :string}
    field :comparison_result, :map

    timestamps()
  end

  @doc false
  def changeset(gpt_comparison, attrs) do
    gpt_comparison
    |> cast(attrs, [:product_skus, :comparison_result])
    |> validate_required([:product_skus, :comparison_result])
  end
end
