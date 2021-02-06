defmodule Sladmin.CMS do
  @moduledoc """
  The CMS context.
  """

  import Ecto.Query, warn: false
  alias Sladmin.Repo
  alias Sladmin.Utils.CharacterFrequency
  alias Sladmin.Integrations.SalesloftApiGateway
  require Logger

  alias Sladmin.CMS.Person

  @doc """
  Returns the list of people.

  ## Examples

      iex> list_people()
      [%Person{}, ...]

  """
  def list_people() do
    SalesloftApiGateway.get_all_people()
  end

  @doc """
  Returns character counts of every string in the list

  ## Examples

      iex> count_characters_in_string(["bob@gmail.com"])
      %{"B" => 2}, ...

  """
  def get_people_character_frequency() do
    # use streams for lazy computation
    SalesloftApiGateway.get_all_people()
    |> Stream.map(&Map.get(&1, :email_address))
    |> Stream.filter(&(!!&1))
    |> Task.async_stream(&CharacterFrequency.calculate/1)
    |> Enum.reduce(%{}, fn {:ok, map}, acc ->
      Map.merge(acc, map, fn _k, v1, v2 -> v1 + v2 end)
    end)
    |> Map.to_list()
    |> Enum.sort_by(fn {_k, v} -> v end, :desc)
    |> Enum.map(fn {k, v} -> %{letter: k, count: v} end)
  end
end
