defmodule Sladmin.Integrations.SalesloftApiGateway do
  require Logger
  alias Sladmin.CMS.Person

  @options [ssl: [{:versions, [:"tlsv1.2"]}], timeout: 10000, recv_timeout: 10000]
  @base_url "https://api.salesloft.com/v2/people.json"
  @headers [
    Authorization: "Bearer #{System.get_env("SALESLOFT_API_KEY")}",
    Accept: "Application/json; Charset=utf-8"
  ]

  @doc """
  Return list of all people from specified page to end, defaults to 1

    ## Examples

      iex> get_all_people
      [%Person{}, ...]

      iex> get_all_people(nil)
      []
  """
  def get_all_people, do: get_people_by_page(1)

  def get_people_by_page(nil), do: []

  def get_people_by_page(page) do
    url = "#{@base_url}?per_page=100&page=#{page}"
    Logger.info("Requesting people info for page #{page}")

    case make_request(url) do
      {:ok, response} ->
        next_page =
          Map.get(response, "metadata", %{}) |> Map.get("paging", %{}) |> Map.get("next_page")

        people =
          Map.get(response, "data", [])
          |> Enum.map(&Person.apply_changeset(%Person{id: Map.get(&1, "id")}, &1))

        people ++ get_people_by_page(next_page)

      {:error, _} ->
        []
    end
  end

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
end