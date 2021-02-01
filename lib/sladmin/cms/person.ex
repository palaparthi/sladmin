defmodule Sladmin.CMS.Person do
  @moduledoc """
  The Person schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :display_name, :string
    field :email_address, :string
    field :title, :string

    timestamps(inserted_at: :created_at, type: :utc_datetime_usec)
  end

  @doc false
  def apply_changeset(%__MODULE__{id: _id} = person, attrs) do
    person
    |> Ecto.Changeset.cast(attrs, __MODULE__.__schema__(:fields))
    |> Ecto.Changeset.apply_changes()
  end
end
