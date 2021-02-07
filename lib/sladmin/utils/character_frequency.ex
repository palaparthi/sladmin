defmodule Sladmin.Utils.CharacterFrequency do
  @moduledoc """
    This utility module has the functions required to calculate character frequency of string.
  """

  @doc """
  Returns map of character counts a

  ## Examples

      iex> calculate("bob@gmail.com")
      %{"B" => 2, ...}
      iex> calculate("")
      %{}
  """

  def calculate(""), do: %{}

  def calculate(s) do
    s
    |> String.codepoints()
    |> Enum.reduce(%{}, fn c, acc ->
      upper_char = String.upcase(c)
      val = Map.get(acc, upper_char, 0) + 1
      Map.put(acc, upper_char, val)
    end)
  end

  def calculate_for_list([]), do: %{}

  def calculate_for_list(li) do
    li
    |> Task.async_stream(&calculate/1)
    # merge and add count for all strings
    |> Enum.reduce(%{}, fn {:ok, map}, acc ->
      Map.merge(acc, map, fn _k, v1, v2 -> v1 + v2 end)
    end)
    |> Map.to_list()
    |> Enum.sort_by(fn {_k, v} -> v end, :desc)
  end
end
