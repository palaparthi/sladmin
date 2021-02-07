defmodule Sladmin.CMS do
  @moduledoc """
  The CMS context.
  """

  import Ecto.Query, warn: false

  alias Sladmin.Repo
  alias Sladmin.Utils.{CharacterFrequency, Levenshtein}
  alias Sladmin.Integrations.SalesloftApiGateway
  alias Sladmin.CMS.Person

  require Logger

  @levenshtein_edit_distance 1

  @doc """
  Returns the list of people.

  ## Examples

      iex> list_people()
      {:ok, [%Person{}, ...]}

    iex> list_people()
      {:error, msg}

  """
  def list_people() do
    case SalesloftApiGateway.get_all_people() do
      {:error, msg} -> {:error, msg}
      people -> {:ok, people}
    end
  end

  @doc """
  Returns character counts of every string in the list

  ## Examples

      iex> get_people_character_frequency(["bob@gmail.com"])
      {:ok, %{"B" => 2}, ...}

    iex> get_people_character_frequency(["bob@gmail.com"])
      {:error, msg}

  """
  def get_people_character_frequency() do
    case SalesloftApiGateway.get_all_people() do
      {:error, msg} ->
        {:error, msg}

      people ->
        {:ok,
         people
         |> Enum.filter(&(!!&1.email_address))
         |> Enum.map(&Map.get(&1, :email_address))
         |> CharacterFrequency.calculate_for_list()
         |> Enum.map(fn {k, v} -> %{letter: k, count: v} end)}
    end
  end

  @doc """
  Returns Person struct from given map

  ## Examples

      iex> convert_to_person(%{id => 1, display_name => "bob, email_address => "bob@gmail.com"})
      %Person{id: 1, ..}

  """
  def convert_to_person(attrs) do
    Person.apply_changeset(%Person{id: Map.get(attrs, "id")}, attrs)
  end

  @doc """
  Returns list of possible duplicates

  ## Examples

      iex> get_possible_duplicates_from_people([%Person{id => 1 ..},..], [%Person{id => 1 ..},..])
      [%Person{id: 1, ..}, %Person{id: 1, ..}]

    iex> get_possible_duplicates_from_people([[], []])
      []
  """
  def get_possible_duplicates_from_people(people_by_domain) do
    people_by_domain
    |> Task.async_stream(fn people ->
      for p1 <- people, p2 <- people, reduce: [] do
        acc ->
          if Levenshtein.compare(p1.email_address, p2.email_address) ===
               @levenshtein_edit_distance,
             do: [p1 | [p2 | acc]],
             else: acc
      end
      |> Enum.uniq_by(& &1.email_address)
    end)
    |> Enum.reduce([], fn {:ok, li}, acc -> if !Enum.empty?(li), do: li ++ acc, else: acc end)
  end

  @doc """
  Returns list of list of people grouped by domain.

  ## Examples

      iex> bucket_people_by_domain([%Person{id: 1, ..}, ..])
      [[%Person{id: 1, ..} ..], [%Person{id: 1, ..} ..]]
  """
  def bucket_people_by_domain(people) do
    people
    |> Enum.group_by(&(String.split(&1.email_address, "@") |> List.last()))
    |> Map.values()
  end

  @doc """
  Returns list of possible duplicates in a domain.

  ## Examples

      iex> list_duplicate_emails()
      {:ok, [%Person{id: 1, ..}, ...]}

    iex> list_duplicate_emails()
      {:error, msg}
  """
  def list_duplicate_emails() do
    case SalesloftApiGateway.get_all_people() do
      {:error, msg} ->
        {:error, msg}

      people ->
        {:ok,
         people
         |> Enum.filter(&(!!&1.email_address))
         # split emails into buckets by domain
         |> bucket_people_by_domain()
         # run levenshtein concurrently per bucket
         |> get_possible_duplicates_from_people()}
    end
  end
end
