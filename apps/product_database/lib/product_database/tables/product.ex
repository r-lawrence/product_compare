defmodule ProductDatabase.Tables.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "products" do
    field :name, :string
    field :image, :string
    field :features, {:array, :string}
    field :sku, :string
    field :price, :string

    has_one :reviews, ProductDatabase.Tables.Review
    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:sku, :image, :price, :name, :features])
    |> validate_required([:sku, :image, :price, :name, :features])
  end
end
