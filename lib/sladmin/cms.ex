defmodule Sladmin.CMS do
  @moduledoc """
  The CMS context.
  """

  import Ecto.Query, warn: false
  alias Sladmin.Repo
  require Logger

  alias Sladmin.CMS.Person

  @options [ssl: [{:versions, [:"tlsv1.2"]}], timeout: 1500, recv_timeout: 1500]
  @base_url "https://api.salesloft.com/v2/people.json"
  @headers [
    Authorization: "Bearer #{System.get_env("SALESLOFT_API_KEY")}",
    Accept: "Application/json; Charset=utf-8"
  ]

  @doc """
  Make Http request

    ## Examples

      iex> make_request(url)
      {:ok, body}

      iex> make_request(user)
      {:error, msg}
  """
  defp make_request(url) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.get(url, @headers, @options),
         {:ok, decoded_response} <- Jason.decode(body) do
      {:ok, decoded_response}
    else
      {:error, msg} ->
        Logger.error("Request failed for url #{url}, message - #{inspect(msg)}")
        {:error, msg}
    end
  end

  @doc """
  Return list of all people from specified page to end, defaults to 1

    ## Examples

      iex> get_all_people(1)
      [%Person{}, ...]

      iex> get_all_people(nil)
      []
  """
  def get_all_people(page \\ 1)

  def get_all_people(nil), do: []

  def get_all_people(page) do
    url = "#{@base_url}?per_page=100&page=#{page}"
    Logger.info("Requesting people info for page #{page}")

    case make_request(url) do
      {:ok, response} ->
        next_page =
          Map.get(response, "metadata", %{}) |> Map.get("paging", %{}) |> Map.get("next_page")

        people =
          Map.get(response, "data", [])
          |> Enum.map(&Person.apply_changeset(%Person{id: Map.get(&1, "id")}, &1))

        people ++ get_all_people(next_page)

      {:error, _} ->
        []
    end
  end

  @doc """
  Returns the list of people.

  ## Examples

      iex> list_people()
      [%Person{}, ...]

  """
  def list_people() do
    get_all_people()
  end

  @doc """
  Returns character counts a string

  ## Examples

      iex> count_characters_in_string("bob@gmail.com")
      %{"B" => 2, ...}

  """
  def count_characters_in_string(str) do
    str
    |> String.codepoints()
    |> Enum.reduce(%{}, fn c, acc ->
      upper_char = String.upcase(c)
      val = Map.get(acc, upper_char, 0) + 1
      Map.put(acc, upper_char, val)
    end)
  end

  @doc """
  Returns character counts of every string in the list

  ## Examples

      iex> count_characters_in_string(["bob@gmail.com"])
      %{"B" => 2}, ...

  """
  def get_people_character_frequency() do
    # use streams for lazy computation
    get_all_people()
    |> Stream.map(&Map.get(&1, :email_address))
    |> Stream.filter(&(!!&1))
    |> Task.async_stream(&count_characters_in_string/1)
    |> Enum.reduce(%{}, fn {:ok, map}, acc ->
      Map.merge(acc, map, fn _k, v1, v2 -> v1 + v2 end)
    end)
    |> Map.to_list()
    |> Enum.sort_by(fn {_k, v} -> v end, :desc)
    |> Enum.map(fn {k, v} -> %{letter: k, count: v} end)
  end
end
