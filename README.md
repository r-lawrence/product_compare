# ProductCompare

## Introduction

### ProductCompare is an application built to allow for a user to compare products on BestBuy. It screen scrapes/displays product information/features, overall product analysis, and individual product review analysis.  ChatGPT powers the review and overall comparison analyses.

## Prerequisites

- Elixir programming language, Phoenix framework, Postgresql, and chromedriver must be installed locally.

- You will need to register for a ChatGPT API key.
 
## Installation
1. Export your ChatGPT api key using `export GPT_API_KEY=YOUR_KEY_HERE`

2. Open a new terminal and start chromediver using `chromedriver`

3. From root directory of project run 
    - `mix deps.get` to get all dependencies.

    - `mix deps.compile` to compile the application

    - `mix ecto.create` to create the database

    - `mix ecto.migrate` to run database migrations
    
    - run `mix phx.server` to start the server.
    
8. navigate to http://localhost:4000 to view the application

# Diagram of Communication
> The below diagram illustrates the communication for when all products need to be scraped and saved. In cases where some of the products are already present, scrape/save and gpt request processes are only established for unknown products.

![](/app_diagrams/productcompare_all_products_request_diagram.png)