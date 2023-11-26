defmodule Scrapers.BestBuyScrape do
  @moduledoc """
  Documentation for `Scrapers.BestBuyScrape`.
  """
  use Hound.Helpers

  def navigate_and_scrape(url) do
    Hound.start_session

    [product_sku] = URI.decode_query(url) |> Map.values()

    navigate_to(url)

    #pulls general product info
    image_src = get_img_url()
    product_price = get_product_price()
    product_name = get_product_name()
    product_features = get_product_features()

    #sleep functionality on webpage for onesecond to allow element to be clickable
    :timer.sleep(1000)

    ## handles pulling review data
    see_more_reviews_button = find_element(:class, "see-more-reviews")

    click(see_more_reviews_button)

    find_element(:css, "#ugc-sort-reviews-sv-#{product_sku} option[value='MOST_HELPFUL']") |> click()

    reviews_html = find_element(:class, "reviews-list") |> inner_html()

    reviews = parse_reviews(reviews_html)
    Hound.end_session()

  %{
    product_sku: product_sku,
    image_src: image_src,
    product_price: product_price,
    product_name: product_name,
    product_features: product_features,
    product_reviews: reviews
  }
  end

  defp get_img_url() do
    find_element(:class, "primary-image")
    |> attribute_value("src")
  end

  defp get_product_price() do
    {:ok, product_price_html} =
      find_element(:class, "priceView-customer-price")
      |> inner_html()
      |> Floki.parse_document()

    product_price_html
    |> List.first()
    |> Floki.text()
  end

  defp get_product_name() do
    {:ok, product_name_html} =
      find_element(:class, "sku-title")
      |> inner_html()
      |> Floki.parse_document()

    product_name_html
    |> List.first()
    |> Floki.text()
    |> String.split("-", trim: true)
    |> Enum.take(2)
    |> Enum.join(" - ")
  end

  defp get_product_features() do
    find_element(:class, "features-drawer-btn") |> click()

    {:ok, features_html} =
      find_element(:class, "pdp-utils-product-info")
      |> inner_html()
      |> Floki.parse_document()

    features =
      features_html
      |> Floki.find("li")
      |> Floki.find("p")
      |> Enum.map(&Floki.text/1)


    find_element(:class, "c-overlay-backdrop") |> click()

    features
  end

  defp parse_reviews(html) do
    {:ok, doc} = Floki.parse_document(html)
    ## here we need to update this functionality to only take p.pre-white-space from
    ## user reviews only and not brand responses

    Floki.find(doc, "p.pre-white-space") |> Enum.take(3) |> Enum.map(&Floki.text/1)
  end



end
