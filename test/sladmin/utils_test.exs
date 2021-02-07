defmodule Sladmin.UtilsTest do
  use Sladmin.DataCase

  describe "levenshtein" do
    alias Sladmin.Utils.Levenshtein

    test "compare/2 returns 0 for empty strings" do
      assert Levenshtein.compare("", "") == 0
    end

    test "compare/2 returns 0 for same strings" do
      assert Levenshtein.compare("bob@gmail.com", "bob@gmail.com") == 0
    end

    test "compare/2 returns 1, insert" do
      assert Levenshtein.compare("bob@gmail.com", "bo@gmail.com") == 1
    end

    test "compare/2 returns 1, delete" do
      assert Levenshtein.compare("bob@gmail.com", "boba@gmail.com") == 1
    end

    test "compare/2 returns 1, replace" do
      assert Levenshtein.compare("bob@gmail.com", "boc@gmail.com") == 1
    end

    test "compare/2 returns 2" do
      assert Levenshtein.compare("bob@gmail.com", "bia@gmail.com") == 2
    end

    test "compare/2 returns 1, first character replace" do
      assert Levenshtein.compare("bob@gmail.com", "cob@gmail.com") == 1
    end

    test "compare/2 returns 1, last character replace" do
      assert Levenshtein.compare("bob@gmail.com", "bob@gmail.con") == 1
    end
  end

  describe "character frequency" do
    alias Sladmin.Utils.CharacterFrequency

    test "count_characters_in_string/1 returns frequency map" do
      map = %{"X" => 2, "Y" => 2, "Z" => 2, "@" => 1, "C" => 1, "O" => 1, "M" => 1, "." => 1}
      assert CharacterFrequency.calculate("xyz@xyz.com") === map
    end

    test "count_characters_in_string/1 returns empty map" do
      map = %{}
      assert CharacterFrequency.calculate("") === map
    end

    test "count_characters_in_string/1 returns map with size 1" do
      map = %{"X" => 1}
      assert CharacterFrequency.calculate("x") === map
    end

    test "count_characters_in_string/1 returns map with size 2" do
      map = %{"X" => 2}
      assert CharacterFrequency.calculate("xX") === map
    end
  end

  describe "character frequency list" do
    alias Sladmin.Utils.CharacterFrequency

    test "calculate_for_list/1 returns accurate frequencies for 1 item" do
      expected = [{"X", 2}, {"Y", 2}, {"Z", 2}, {".", 1}, {"@", 1}, {"C", 1}, {"M", 1}, {"O", 1}]
      frequencies = CharacterFrequency.calculate_for_list(["xyz@xyz.com"])
      intersection = MapSet.intersection(MapSet.new(frequencies), MapSet.new(expected))
      assert MapSet.size(intersection) == length(frequencies)
    end

    test "calculate_for_list/1 returns accurate frequencies for 2 different items with different domain names" do
      expected = [
        {"X", 2},
        {"Y", 2},
        {"Z", 2},
        {".", 2},
        {"@", 2},
        {"C", 4},
        {"M", 2},
        {"O", 2},
        {"A", 2},
        {"B", 2}
      ]

      frequencies = CharacterFrequency.calculate_for_list(["xyz@xyz.com", "abc@abc.com"])
      intersection = MapSet.intersection(MapSet.new(frequencies), MapSet.new(expected))
      assert MapSet.size(intersection) == length(frequencies)
    end

    test "calculate_for_list/1 returns accurate frequencies for 2 different items with same domain names" do
      expected = [
        {"X", 3},
        {"Y", 3},
        {"Z", 3},
        {".", 2},
        {"@", 2},
        {"C", 3},
        {"M", 2},
        {"O", 2},
        {"A", 1},
        {"B", 1}
      ]

      frequencies = CharacterFrequency.calculate_for_list(["xyz@xyz.com", "abc@xyz.com"])
      intersection = MapSet.intersection(MapSet.new(frequencies), MapSet.new(expected))
      assert MapSet.size(intersection) == length(frequencies)
    end

    test "calculate_for_list/1 returns accurate frequencies for 2 items with different domain names" do
      expected = [
        {"X", 3},
        {"Y", 3},
        {"Z", 3},
        {".", 2},
        {"@", 2},
        {"C", 3},
        {"M", 2},
        {"O", 2},
        {"A", 1},
        {"B", 1}
      ]

      frequencies = CharacterFrequency.calculate_for_list(["xyz@xyz.com", "xyz@abc.com"])
      intersection = MapSet.intersection(MapSet.new(frequencies), MapSet.new(expected))
      assert MapSet.size(intersection) == length(frequencies)
    end

    test "calculate_for_list/1 returns in correct order" do
      expected = [
        {"X", 3},
        {"Y", 3},
        {"Z", 3},
        {".", 2},
        {"@", 2},
        {"C", 3},
        {"M", 2},
        {"O", 2},
        {"A", 1},
        {"B", 1}
      ]

      frequencies = CharacterFrequency.calculate_for_list(["aaacbc"])
      assert frequencies == [{"A", 3}, {"C", 2}, {"B", 1}]
    end

    test "calculate_for_list/1 returns accurate frequencies for empty string" do
      expected = []
      frequencies = CharacterFrequency.calculate_for_list([""])
      intersection = MapSet.intersection(MapSet.new(frequencies), MapSet.new(expected))
      assert MapSet.size(intersection) == length(frequencies)
    end

    test "calculate_for_list/1 returns accurate frequencies for 2 empty strings" do
      expected = []
      frequencies = CharacterFrequency.calculate_for_list(["", ""])
      intersection = MapSet.intersection(MapSet.new(frequencies), MapSet.new(expected))
      assert MapSet.size(intersection) == length(frequencies)
    end

    test "calculate_for_list/1 returns accurate frequencies for string with one space" do
      expected = [{" ", 1}]
      frequencies = CharacterFrequency.calculate_for_list([" "])
      intersection = MapSet.intersection(MapSet.new(frequencies), MapSet.new(expected))
      assert MapSet.size(intersection) == length(frequencies)
    end
  end
end
