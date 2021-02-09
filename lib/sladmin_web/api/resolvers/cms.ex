defmodule SladminWeb.Api.Resolvers.CMS do
  @moduledoc """
  GraphQL resolvers for CMS context.
  All the functions return either {:ok, _} or {:error, _}
  """

  alias Sladmin.CMS

  @doc "Returns list of people with pagination"
  def list_people(%{page: page}, _) do
    CMS.get_people_with_meta(page)
  end

  @doc "Returns list of character frequency of emails of all people"
  def get_people_character_frequency(_, _) do
    CMS.get_people_character_frequency()
  end

  @doc "Returns list of possible duplicate people"
  def list_duplicate_emails(_, _) do
    CMS.list_duplicate_emails()
  end
end