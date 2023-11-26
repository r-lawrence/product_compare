defmodule ProductDatabase.GptComparisonContext do

  import Ecto.Query, warn: false

  alias ProductDatabase.Repo
  alias ProductDatabase.Tables.GptComparison

  def insert(comparison, skus) do

    Repo.insert(
      %GptComparison{
        product_skus: skus,
        comparison_result: comparison
      }
    )

  end

  def get_comparison(list_of_skus) do

    query =
      from g in GptComparison,
      where: fragment("? @> ?", g.product_skus, ^list_of_skus),
      select: g

    Repo.one(query)
  end

end
