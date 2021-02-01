defmodule Sladmin.CMS do
  @moduledoc """
  The CMS context.
  """

  import Ecto.Query, warn: false
  alias Sladmin.Repo
  require Logger

  alias Sladmin.CMS.Person

  @doc """
  Make Http request

    ## Examples

      iex> make_request(url)
      {:ok, body}

      iex> make_request(user)
      {:error, msg}
  """
  defp make_request(url) do
    token = Application.get_env(:sladmin, :salesloft_api_key)
    headers = [Authorization: "Bearer #{token}", Accept: "Application/json; Charset=utf-8"]
    options = [ssl: [{:versions, [:"tlsv1.2"]}], recv_timeout: 500]

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.get(url, headers, options),
         {:ok, decoded_response} <- Jason.decode(body) do
      {:ok, decoded_response}
    else
      {:error, msg} -> {:error, msg}
    end
  end

  @doc """
  Return list people by page

    ## Examples

      iex> make_request(url)
      {:ok, body}

      iex> make_request(user)
      {:error, msg}
  """
  def get_people_by_page(page \\ 0) do
    actual_page = page + 1

    url =
      "https://api.salesloft.com/v2/people.json?include_paging_counts=true&per_page=100&page=#{
        actual_page
      }"

    case make_request(url) do
      {:ok, response} ->
        Map.get(response, "data")
        |> Enum.map(&Person.apply_changeset(%Person{id: Map.get(&1, "id")}, &1))

      {:error, msg} ->
        {:error, msg}
    end
  end

  @doc """
  Returns the list of people.

  ## Examples

      iex> list_people()
      [%Person{}, ...]

  """
  def list_people() do
    # todo: get all pages
    get_people_by_page()
  end
end
