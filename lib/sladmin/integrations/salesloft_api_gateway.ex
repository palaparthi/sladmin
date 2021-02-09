defmodule Sladmin.Integrations.SalesloftApiGateway do
  @moduledoc """
  This module contains, SalesLoft API Gateway functions
  """

  require Logger
  alias Sladmin.CMS

  @options [ssl: [{:versions, [:"tlsv1.2"]}], timeout: 8000]
  @base_url "https://api.salesloft.com/v2/people.json"
  @headers [
    Authorization: "Bearer #{System.get_env("SALESLOFT_API_KEY")}",
    Accept: "Application/json; Charset=utf-8"
  ]
  @retries 2
  @sleep 1000

  @doc """
  Return list of all people from specified page to end, defaults to 1

    ## Examples

      iex> get_all_people
      [%Person{}, ...]

      iex> get_all_people(nil)
      []

      iex> get_all_people(nil)
      {:error, msg}
  """
  def get_all_people, do: get_all_people(1)

  def get_all_people(nil), do: []

  def get_all_people(page) do
    url = "#{@base_url}?per_page=100&page=#{page}"
    Logger.info("Requesting people info for page #{page}")

    case make_request(url, @retries) do
      {:ok, response} ->
        next_page = response |> Map.get("metadata", %{}) |> Map.get("paging", %{}) |> Map.get("next_page")

        people = response |> Map.get("data", []) |> Enum.map(&CMS.convert_to_person(&1))

        people ++ get_all_people(next_page)

      {:error, resp} ->
        {:error, "API request failed, #{resp.reason}"}
    end
  end

  @doc """
  Return person_feed(check GraphQL types)

    ## Examples

      iex> get_people_with_meta(1)
      {:ok, %{people: [%Person{}, ...], pagination_info: %{"current_page" => 1, ...}}

      iex> get_people_with_meta(nil)
      {:error, msg}
  """
  def get_people_with_meta(page) do
    url = "#{@base_url}?per_page=100&page=#{page}"

    case make_request(url, @retries) do
      {:ok, response} ->
        pagination_info = response |> Map.get("metadata", %{}) |> Map.get("paging", %{})
        people = Map.get(response, "data", []) |> Enum.map(&CMS.convert_to_person(&1))

        {:ok, %{people: people, pagination_info: pagination_info}}

      {:error, resp} ->
        {:error, "API request failed, #{resp.reason}"}
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
  defp make_request(url, retries) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <-
           HTTPoison.get(url, @headers, @options),
         {:ok, decoded_response} <- Jason.decode(body) do
      {:ok, decoded_response}
    else
      {:error, msg} ->
        Logger.error(
          "Request failed for url #{url}, message - #{inspect(msg)}, retries- #{retries}"
        )

        case retries do
          0 ->
            {:error, msg}

          r ->
            Process.sleep(@sleep)
            Logger.info("sleep for #{@sleep} seconds before making another call")
            make_request(url, r - 1)
        end
    end
  end
end
