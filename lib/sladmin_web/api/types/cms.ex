defmodule SladminWeb.Api.Types.CMS do
  @moduledoc """
  GraphQL types for CMS context.
  """

  use Absinthe.Schema.Notation

  @desc "SalesLoft person"
  object :person do
    field :id, non_null(:integer)
    field :display_name, :string
    field :email_address, :string
    field :title, :string
  end

  @desc "List of people with pagination info"
  object :people_feed do
    field :people, list_of(:person)
    field :pagination_info, :pagination_info
  end

  @desc "Character frequency of all the emails of people"
  object :character_frequency do
    field :letter, non_null(:string)
    field :count, non_null(:integer)
  end

  @desc "Pagination metadata"
  object :pagination_info do
    field :per_page, non_null(:integer)
    field :current_page,non_null(:integer)
    field :next_page, :integer
    field :prev_page, :integer
  end
end