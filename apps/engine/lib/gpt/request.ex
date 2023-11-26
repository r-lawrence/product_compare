defmodule Gpt.Request do
  @moduledoc """
  Documentation for `Gpt.Request`.
  """

  @api_key Application.compile_env(:engine, :gpt_api_key)


  def make_gpt_request(list) do
    url = "https://api.openai.com/v1/chat/completions"
    api_key = @api_key


    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{api_key}"}
    ]

    payload = %{
      "model" => "gpt-3.5-turbo-16k",

      "messages" => [
        %{"role" => "system", "content" => "You are a helpful assistant.You will be provided a list of reviews for a product on bestbuy. I want you to go through all of the reviews and provide the most common likes and dislikes. Your response needs to be a JSON object that resembles this {likes: [strings representing the most common likes], dislikes: [strings representing the most common dislikes]}."},
        %{"role" => "user", "content" => Jason.encode!(list)}
      ]
    }
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 150_000]


    response = HTTPoison.post(url, Jason.encode!(payload), headers, options)

    case response do
      {:ok, %HTTPoison.Response{body: body}} ->
       [choices] = Jason.decode!(body) |> Map.get("choices")

       choices |> Map.get("message") |> Map.get("content") |> Jason.decode!()

      {:error, %HTTPoison.Error{reason: reason}} ->

        IO.inspect("error #{reason}")
    end
  end

  def make_comparison_request(list) do
    url = "https://api.openai.com/v1/chat/completions"
    api_key = @api_key

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{api_key}"}
    ]

    payload = %{
      "model" => "gpt-3.5-turbo-16k",

      "messages" => [
        %{"role" => "system", "content" => "You are a helpful assistant.  You will receive a list of objects.  Each object is a representation of a product on best buy which includes its name, price, and features.  Using the price and features, I want you to compare all of the products.  Once you have reviewed all the information I want you to provide A) a overall comparison of all of the products, B) the product which is best value for its price, c) the product which has the best performance, regardless of price, and, D) the product which has the overall best value.  I want your response to be in a JSON object that resembles this {overall_comparison: your overall comparison in the form of a string, best_for_price: { name: name of product selected, explanation: explanation of why you chose this product }, best_performance : { name: name of product selected, explanation: explanation of why you chose this product }, best_overall_value: {  name: name of product selected, explanation: explanation of why you chose this product }}.  Please note, unless there is less than three products, you cannot choose the same product for any of the following criteria best_for_price, best_performance, and best_overall_value."},
        %{"role" => "user", "content" => Jason.encode!(list)}
      ]
    }
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 150_000]

    response = HTTPoison.post(url, Jason.encode!(payload), headers, options)


    case response do
      {:ok, %HTTPoison.Response{body: body}} ->
       [choices] = Jason.decode!(body) |> Map.get("choices")

       choices |> Map.get("message") |> Map.get("content") |> Jason.decode!()

      {:error, %HTTPoison.Error{reason: reason}} ->

        IO.inspect("error #{reason}")
    end
  end

end
