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

end