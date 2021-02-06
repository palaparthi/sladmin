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

end