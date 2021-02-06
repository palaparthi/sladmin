defmodule Sladmin.CMSTest do
  use Sladmin.DataCase
  use ExUnit.Case, async: false

  import Mock

  alias Sladmin.CMS

  @mock_resp1 %{
    metadata: %{
      paging: %{next_page: 2}
    },
    data: [%{id: 1, email_address: "xyz@xyz.com", display_name: "xyz"}]
  }

  @mock_resp2 %{
    metadata: %{
      paging: %{next_page: nil}
    },
    data: [%{id: 2, email_address: "abc@abc.com", display_name: "abc"}]
  }

  @page1_url "https://api.salesloft.com/v2/people.json?per_page=100&page=1"
  @page2_url "https://api.salesloft.com/v2/people.json?per_page=100&page=2"

  setup_with_mocks([
    {HTTPoison, [],
     [
       get: fn
         @page1_url, _, _ ->
           {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(@mock_resp1)}}

         @page2_url, _, _ ->
           {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!(@mock_resp2)}}
       end
     ]}
  ]) do
    {:ok, []}
  end

  describe "people" do
    test "list_people/1, 2 calls, returns 1 person per page" do
      people = CMS.list_people()
      assert_called(HTTPoison.get(@page1_url, :_, :_))
      assert_called(HTTPoison.get(@page2_url, :_, :_))
      assert length(people) == 2
    end
  end

  describe "character frequency" do
    test "count_characters_in_string/1 returns frequency map" do
      map = %{"X" => 2, "Y" => 2, "Z" => 2, "@" => 1, "C" => 1, "O" => 1, "M" => 1, "." => 1}
      assert CMS.count_characters_in_string("xyz@xyz.com") === map
    end

    test "count_characters_in_string/1 returns empty map" do
      map = %{}
      assert CMS.count_characters_in_string("") === map
    end

    test "count_characters_in_string/1 returns map with size 1" do
      map = %{"X" => 1}
      assert CMS.count_characters_in_string("x") === map
    end

    test "count_characters_in_string/1 returns map with size 2" do
      map = %{"X" => 2}
      assert CMS.count_characters_in_string("xx") === map
    end

    test "get_people_character_frequency/0 returns all frequencies" do
      frequencies = CMS.get_people_character_frequency()
      assert length(frequencies) == 10
    end

    test "get_people_character_frequency/0 returns all frequencies in desc count order" do
      frequencies = CMS.get_people_character_frequency()
      assert List.first(frequencies).count == 4
      assert List.first(frequencies).letter == "C"
      assert List.last(frequencies).count == 2
    end
  end
end
