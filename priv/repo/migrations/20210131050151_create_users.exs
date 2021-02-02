defmodule Sladmin.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :text
      add :email, :text

      timestamps(type: :timestamptz)
    end

    create_if_not_exists unique_index(:users, [:email])
  end
end
