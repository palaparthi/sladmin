defmodule Sladmin.Utils.Levenshtein do
  @moduledoc """
    This utility module has the functions required to calculate the memoized levenshtein distance between two strings.
    finds minimum INSERT, REPLACE, DELETE operations needed to transform one string to another
  """

  @doc """
    Calculates the levenshtein distance between two strings

    iex> compare("", "")
          0

    iex> compare("rose", "ros")
          1
  """

  def compare(s, s), do: 0

  def compare(s1, s2) do
    distance(to_charlist(s1), to_charlist(s2))
  end

  defp store_result(key, dist, cache) do
    {dist, Map.put(cache, key, count)}
  end

  defp distance(x, y), do: distance(x, y, Map.new()) |> elem(0)

  defp distance(x, [] = y, cache), do: store_result({x, y}, length(x), cache)

  defp distance([] = x, y, cache), do: store_result({x, y}, length(y), cache)

  # if the first element is the same in both parts, then we don't need to consider that element,
  # as there won't be any need to perform any operation.
  defp distance([x | r1], [x | r2], cache) do
    distance(r1, r2, cache)
  end

  defp distance([_ | r1] = x, [_ | r2] = y, cache) do
    key = {x, y}

    case Map.has_key?(cache, key) do
      true ->
        {Map.get(cache, key), cache}

      false ->
        {dist1, cache1} = distance(x, r2, cache)
        {dist2, cache2} = distance(r1, y, cache1)
        {dist3, cache3} = distance(r1, r2, cache2)

        min = Enum.min([dist1, dist2, dist3]) + 1
        store_result(key, min, cache3)
    end
  end
end
