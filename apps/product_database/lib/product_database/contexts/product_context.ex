defmodule ProductDatabase.ProductContext do

  import Ecto.Query, warn: false

  alias ProductDatabase.Repo
  alias ProductDatabase.Tables.Product

  def insert_product(
    %{
      product_sku: sku,
      image_src: image,
      product_price: price,
      product_name: name,
      product_features: features
      } = _product
  ) do

    ## create changeset with product map received
    ## insert changset into database

    Repo.insert(%Product{
      sku: sku,
      image: image,
      price: price,
      name: name,
      features: features
    })
  end

  def get_products(list_of_skus) do
    ## this might get expensive depending on how many records are in database??
    query =
      from p in Product,
      join: r in assoc(p, :reviews),
      where: p.sku in ^list_of_skus,
      select: {p, r.summary}

    Repo.all(query)
  end
end
