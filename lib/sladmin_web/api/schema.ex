defmodule SladminWeb.Api.Schema do
  @moduledoc """
  GraphQL schema module.
  """

  use Absinthe.Schema
  import_types(SladminWeb.Api.Types.CMS)
  alias SladminWeb.Api.Resolvers

  # GraphQL queries
  query do
    @desc "Returns list of people with pagination info"
    field :list_people, :people_feed do
      arg :page, :integer, default_value: 1
      resolve(&Resolvers.CMS.list_people/2)
    end

    @desc "Returns list of character frequency of all the emails of people"
    field :people_character_frequency, list_of(:character_frequency) do
      resolve(&Resolvers.CMS.get_people_character_frequency/2)
    end

    @desc "Returns list of possible duplicate people"
    field :duplicate_people, list_of(:person) do
      resolve(&Resolvers.CMS.list_duplicate_emails/2)
    end
  end

  # middleware, convert string map to atom map for pagination_info
  def middleware(middleware, %{identifier: identifier} = field, %{identifier: :pagination_info} = object) do
    middleware_spec = {Absinthe.Middleware.MapGet, Atom.to_string(identifier)}
    Absinthe.Schema.replace_default(middleware, middleware_spec, field, object)
  end

  def middleware(middleware, _, _) do
    middleware
  end
end
