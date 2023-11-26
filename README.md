# ProductCompare

## Introduction

### ProductCompare is an application built to allow for a user to compare products on BestBuy. 

## Installation

> In order to run this application locally, you will need to have chromedriver installed and started.

> You also need to have postgresql installed and started on your local machine.

> you will need a GPT API key.  Once you have registered for one, run `export GPT_API_KEY=YOUR_API_KEY` before compiling your application to ensure its present when application is running.

1. run `mix deps.get` to get all depencies.
2. run `mix deps.compile` to compile the application.
3. run `mix ecto.create` to create the database.
4. run `mix ecto.migrate` to run database migrations.
5. run `mix phx.server`
6. navigate to http://localhost:4000 to view the application
