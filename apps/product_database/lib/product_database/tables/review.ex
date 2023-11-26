defmodule ProductDatabase.Tables.Review do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "reviews" do
    field :reviews, {:array, :string}
    field :summary, :map
    belongs_to :product, ProductDatabase.Tables.Product

    timestamps()
  end

  @doc false
  def changeset(review, attrs) do
    review
    |> cast(attrs, [:reviews, :summary])
    |> validate_required([:reviews])

  end


end
