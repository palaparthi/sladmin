# Sladmin

This project uses Elixir, GraphQL(Absinthe), PostgreSQL and React.

## Steps to run the project
  * Create `.env` file in the root and add `SALESLOFT_API_KEY`, check `.env.sample` for reference
  * Install docker and run `docker-compose build`
  * Run `docker-compose up`
  * Visit [`localhost:4040`](http://localhost:4040) from your browser after building

  
## Steps to run the tests
Install Elixir, PostgreSQL and run `mix test`

## Running without docker

To start your Phoenix server without docker, install Elixir, PostgreSQL and follow the below steps:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`
  * Visit [`localhost:4040`](http://localhost:4040)

### TODOS
  * Cache external API requests on the backend
  * Add client tests
  * Add Authentication, create user etc.
