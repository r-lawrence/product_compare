defmodule Engine do
  @moduledoc """
  Documentation for `WebScrapingEngine`.
  """

  alias Scrapers.BestBuyScrape
  alias ProductDatabase.Tables.Product
  alias ProductDatabase.Tables.Review
  alias ProductDatabase.ProductContext
  alias ProductDatabase.ReviewContext
  alias ProductDatabase.GptComparisonContext
  alias ProductDatabase.Tables.GptComparison
  alias Gpt.Request
  ## this is not dry and needs to be refactored but its working
  def get_product_information(urls) do
    ## determine which data is present
    sku_url_map =
      urls
      |> Enum.reduce(%{},
        fn url, acc ->
          [product_sku] = URI.decode_query(url) |> Map.values()
          Map.put(acc, product_sku, url)
        end
      )

    sku_list = Map.keys(sku_url_map)

    case ProductContext.get_products(sku_list) do
      [{_product_1, _review_summary_1}, {_product_2, _review_summary_2}, {_product_3, _review_summary_3}] = database_response ->
        ## all are present
        ## configure and send all data (establish client overload to handle adding product_data)

        %GptComparison{
          comparison_result: overall_comparison
        } = GptComparisonContext.get_comparison(sku_list)

        product_data = configure_product_data_for_publish(database_response)

        %{result: product_data, overall_comparison: overall_comparison}


      result ->
         ## some may be present and some might not be

         case result do
          [] ->
            #everything needs to be requested

            scraping_tasks = Enum.map(urls, fn url -> Task.async(fn -> scrape_n_save(url) end) end)

            results = Enum.map(scraping_tasks, &Task.await(&1, 60_000))

            filtered_product_results = configure_product_data_for_publish(results)

            ## publish results for frontend
            Phoenix.PubSub.broadcast(ProductDatabase.PubSub, "product_saved", filtered_product_results)

            ## begin gtp_requests with review data
            filtered_review_results = configure_review_data_for_gpt_request(results)

            gpt_review_anaylsis_requests = Enum.map(
              filtered_review_results,
              fn %{product_id: _id, reviews: reviews} ->
                Task.async(fn -> Request.make_gpt_request(reviews) end)
              end
            )

            gpt_results = Enum.map(gpt_review_anaylsis_requests, &Task.await(&1, 300_000))


            ## update each review in database with each review anaylsis
            review_summary_update_tasks =
              Enum.zip(results, gpt_results)
              |> Enum.map(
                fn
                  {{:ok, %{review: review}}, review_summary} ->
                  Task.async(fn -> ReviewContext.update_summary(review, review_summary) end)
                end
              )

            review_summary_results = Enum.map(review_summary_update_tasks, &Task.await(&1, 5_000))

            ## here send summary results for reviews and overall gpt summary

            overall_comparison = make_comparison_request(filtered_product_results)

            review_summary_result = format_review_summary_for_response(review_summary_results)

            %{result: review_summary_result, overall_comparison: overall_comparison}

          _some_items_present ->

            ## configure data that is present into subscription list
            subscription_list = configure_product_data_for_publish(result)
            ## scrape/save data that isnt present

            present_data = Enum.map(
              subscription_list,
              fn %{sku: sku} ->
                sku
              end
            )

            all_skus = Map.keys(sku_url_map)

            not_present_skus = Enum.reject(all_skus, &Enum.member?(present_data, &1))

            urls_to_scrape =
              not_present_skus
              |> Enum.map(
                fn sku ->
                  Map.get(sku_url_map, sku)
                end
              )

            scraping_tasks = Enum.map(urls_to_scrape, fn url -> Task.async(fn -> scrape_n_save(url) end) end)

            results = Enum.map(scraping_tasks, &Task.await(&1, 60_000))

            unfinished_product_results = configure_product_data_for_publish(results)

            publish_data = subscription_list ++ unfinished_product_results

            Phoenix.PubSub.broadcast(ProductDatabase.PubSub, "product_saved", publish_data)

            filtered_review_results = configure_review_data_for_gpt_request(results)

            gpt_review_anaylsis_requests = Enum.map(
              filtered_review_results,
              fn %{product_id: _id, reviews: reviews} ->
                Task.async(fn -> Request.make_gpt_request(reviews) end)
              end
            )

            gpt_results = Enum.map(gpt_review_anaylsis_requests, &Task.await(&1, 300_000))

            review_summary_update_tasks =
              Enum.zip(results, gpt_results)
              |> Enum.map(
                fn
                  {{:ok, %{review: review}}, review_summary} ->
                  Task.async(fn -> ReviewContext.update_summary(review, review_summary) end)
                end
              )

            review_summary_results = Enum.map(review_summary_update_tasks, &Task.await(&1, 5_000))

            overall_comparison = make_comparison_request(publish_data)

            review_summary_result = format_review_summary_for_response(review_summary_results)

            %{result: review_summary_result, overall_comparison: overall_comparison}

         end
    end
  end

  def make_comparison_request(list) do
    skus =
      list
      |> Enum.map(
        fn %{sku: sku} ->
          sku
        end
      )

    case GptComparisonContext.get_comparison(skus) do
      nil ->
        IO.inspect("hitting save")
        request_list =
          list
          |> Enum.map(
            fn %{name: name, price: price, features: features} ->
              %{name: name, price: price, features: features}
            end
          )

        comparison_map = Request.make_comparison_request(request_list)

        GptComparisonContext.insert(comparison_map, skus)

        comparison_map

      %GptComparison{comparison_result: result} ->
        IO.inspect("hitting saved--")

        result
    end
  end

  def get_previous_search_data(list_of_skus) do

    %GptComparison{
      comparison_result: overall_comparison
    } = GptComparisonContext.get_comparison(list_of_skus)

    products = ProductContext.get_products(list_of_skus)

    product_data = configure_product_data_for_publish(products)

    %{result: product_data, overall_comparison: overall_comparison}
  end

  defp scrape_n_save (url) do
    %{
      product_sku: sku,
      image_src: image,
      product_price: price,
      product_name: name,
      product_features: features,
      product_reviews: reviews
    } = BestBuyScrape.navigate_and_scrape(url)

    product_record = %{
      product_sku: sku,
      image_src: image,
      product_price: price,
      product_name: name,
      product_features: features
    }

    with {:ok, %Product{id: id, name: _name, image: _image, features: _features, sku: _sku, price: _price} = product} <- ProductContext.insert_product(product_record),
      {:ok, %Review{} = review} <- ReviewContext.insert_review(%{product_id: id, reviews: reviews})
    do
      {:ok, %{product: product, review: review}}
    else
      err ->
        {:error, err}
    end
  end

  defp configure_product_data_for_publish(product_data_list) do
    Enum.map(product_data_list,
      fn tuple ->
        case tuple do
          {:ok, %{product: %Product{id: id, name: name, image: image, features: features, sku: sku, price: price}}} ->
            %{id: id, name: name, image: image, features: features, sku: sku, price: price, review_summary: nil}

          {%Product{id: id, name: name, image: image, features: features, sku: sku, price: price}, review_summary} ->

            %{id: id, name: name, image: image, features: features, sku: sku, price: price, review_summary: review_summary}

        _ ->
          nil
        end
    end)
  end

  defp configure_review_data_for_gpt_request(product_data_list) do
    Enum.map(product_data_list,
    fn tuple ->
      case tuple do
        {:ok, %{review: %Review{product_id: product_id, reviews: reviews}}} ->
          %{product_id: product_id, reviews: reviews}
      _ ->
        nil
      end
    end)
  end

  defp format_review_summary_for_response(review_list) do
    Enum.map(review_list,
      fn tuple ->
        case tuple do
          {:ok, %Review{product_id: product_id, summary: review_summary}} ->
            %{product_id: product_id, review_summary: review_summary}
          _ ->
            nil
        end
      end
    )
  end
end
