defmodule ProductDatabase.ReviewContext do

  import Ecto.Query, warn: false

  alias ProductDatabase.Repo
  alias ProductDatabase.Tables.Review

  def insert_review (%{product_id: product_id, reviews: reviews}= _review) do
    Repo.insert(%Review{
      product_id: product_id,
      reviews: reviews
    })
  end

  def update_summary(current_review, summary) do
    changeset = Review.changeset(current_review, %{summary: summary})
    Repo.update(changeset)
  end

end
