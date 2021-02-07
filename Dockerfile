FROM bitwalker/alpine-elixir-phoenix:latest

WORKDIR /app

COPY mix.exs .
COPY mix.lock .

RUN mkdir assets

COPY assets/package.json assets
COPY assets/package-lock.json assets
COPY assets/webpack.config.js assets
COPY assets/tsconfig.json assets
COPY assets/.babelrc assets

CMD mix deps.get && cd assets && npm install && cd .. && mix phx.server