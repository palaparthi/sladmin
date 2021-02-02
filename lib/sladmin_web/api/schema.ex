defmodule SladminWeb.Api.Schema do
  use Absinthe.Schema

  object :person do
    field :id, :integer
    field :display_name, :string
    field :email_address, :string
    field :title, :string
  end

  query do
    field :people, list_of(:person) do
      resolve(fn _, _ ->
        people = Sladmin.CMS.list_people()
        {:ok, people}
      end)
    end
  end
end
