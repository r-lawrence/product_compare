defmodule ProductCompareWeb.CompareLive do
  use ProductCompareWeb, :live_view

  alias Engine
  alias Phoenix.LiveView

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(ProductDatabase.PubSub, "product_saved")

    {:ok,
      socket
      |> assign(:user_input, %{"url_1" => "", "url_2" => "", "url_3" => ""})
      |> assign(:product_data, nil)
      |> assign(:overall_comparison, nil)
    }


  end

  def handle_event("submit", url_map, socket) do

    ## this needs to get refactored so that existing products can be retrieved
    ## and new products can be scraped.

    ## start by querying the database based on the product-sku in the url
      ## when product is present in the database, add it to the product_data list
    url_list =
      url_map
        |> Map.values()
        |> Enum.filter(& &1 != "")

    # handle_product_fetch(url_list)

    {:noreply,
      socket
      |> assign(:product_data, LiveView.AsyncResult.loading())
      |> start_async(:fetch_data, fn -> Engine.get_product_information(url_list) end)
    }
  end


  def handle_info(msg, socket) do
    %{product_data: product_data} = socket.assigns

    {:noreply, assign(socket, :product_data, LiveView.AsyncResult.ok(product_data, msg))}
  end

  def handle_async(:fetch_data, {:ok, %{result: result, overall_comparison: overall_comparison}}, socket) do
    %{product_data: product_data} = socket.assigns

    case List.first(result) do
      %{id: _, name: _, image: _, features: _, sku: _, price: _, review_summary: _} ->
        ## received entire cached data, set product data
        {:noreply,
          socket
          |> assign(:product_data, LiveView.AsyncResult.ok(product_data, result))
          |> assign(:overall_comparison, overall_comparison)
        }

      %{product_id: _, review_summary: _} ->
        ## reivied summary response
        ## add summary to exisiting data

        new_product_data = Enum.map(product_data.result, fn product_map ->

          case product_map[:review_summary] do
            nil ->
              # product review needs to be added

              review_summary = Enum.find(
                result,
                fn %{product_id: product_id} ->
                  product_id == product_map[:id]
                end
              )
              Map.put(product_map, :review_summary, review_summary[:review_summary])
            _already_present ->
              product_map
          end
        end)

        {:noreply,
          socket
          |> assign(:product_data, LiveView.AsyncResult.ok(product_data, new_product_data))
          |> assign(:overall_comparison, overall_comparison)
        }
    end
  end

  def render(assigns) do
    Phoenix.Template.render(ProductCompareWeb.CompareLiveHTML, "compare_live", "html", assigns)
  end


end
