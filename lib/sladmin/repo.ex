defmodule Sladmin.Repo do
  use Ecto.Repo,
    otp_app: :sladmin,
    adapter: Ecto.Adapters.Postgres
end
