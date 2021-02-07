defmodule Sladmin.CMSTest do
  use Sladmin.DataCase
  use ExUnit.Case, async: false

  import Mock

  alias Sladmin.CMS
  alias Sladmin.CMS.Person

  @mock_resp1 %{
    metadata: %{
      paging: %{next_page: 2}
    },
    data: [
      %{id: 1, email_address: "xyz@xyz.com", display_name: "xyz"}
    ]
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
      {:ok, people} = CMS.list_people()
      assert_called(HTTPoison.get(@page1_url, :_, :_))
      assert_called(HTTPoison.get(@page2_url, :_, :_))
      assert length(people) == 2
    end
  end

  describe "character frequency" do
    test "get_people_character_frequency/0 returns all frequencies" do
      {:ok, frequencies} = CMS.get_people_character_frequency()
      assert length(frequencies) == 10
    end

    test "get_people_character_frequency/0 returns all frequencies in desc count order" do
      {:ok, frequencies} = CMS.get_people_character_frequency()
      assert List.first(frequencies).count == 4
      assert List.first(frequencies).letter == "C"
      assert List.last(frequencies).count == 2
    end
  end

  describe "convert_to_person" do
    test "convert_to_person/1 returns person" do
      assert CMS.convert_to_person(%{"id" => 1, "email_address" => "xyz@xyz.com"}) ==
               %Person{id: 1, email_address: "xyz@xyz.com"}
    end
  end

  describe "get_possible_duplicates" do
    test "list_duplicate_emails/0 returns list" do
      assert CMS.list_duplicate_emails() == []
    end

    test "get_possible_duplicates_from_people/1 empty list returns list" do
      assert CMS.get_possible_duplicates_from_people([]) == []
    end

    test "get_possible_duplicates_from_people/1 empty list of lists returns list" do
      assert CMS.get_possible_duplicates_from_people([[]]) == []
    end

    test "get_possible_duplicates_from_people/1 same domain one duplicate returns 2" do
      people = [
        [
          %Person{id: 1, email_address: "bob@gmail.com"},
          %Person{id: 2, email_address: "bib@gmail.com"},
          %Person{id: 3, email_address: "cab@gmail.com"}
        ]
      ]

      emails = CMS.get_possible_duplicates_from_people(people) |> Enum.map(& &1.email_address)

      assert Enum.member?(emails, "bob@gmail.com")
      assert Enum.member?(emails, "bib@gmail.com")
      assert length(emails) === 2
    end

    test "get_possible_duplicates_from_people/1 same domain same person, returns 0" do
      people = [
        [
          %Person{id: 1, email_address: "bob@gmail.com"},
          %Person{id: 2, email_address: "bob@gmail.com"}
        ]
      ]

      emails = CMS.get_possible_duplicates_from_people(people) |> Enum.map(& &1.email_address)

      assert length(emails) === 0
    end

    test "get_possible_duplicates_from_people/1 same domain one all different length, return 0" do
      people = [
        [
          %Person{id: 1, email_address: "alice@gmail.com"},
          %Person{id: 2, email_address: "ric@gmail.com"},
          %Person{id: 3, email_address: "alice_bob@gmail.com"}
        ]
      ]

      emails = CMS.get_possible_duplicates_from_people(people) |> Enum.map(& &1.email_address)
      assert length(emails) === 0
    end

    test "get_possible_duplicates_from_people/1 same domain all duplicates different length" do
      people = [
        [
          %Person{id: 1, email_address: "bob@gmail.com"},
          %Person{id: 2, email_address: "bib@gmail.com"},
          %Person{id: 3, email_address: "bobi@gmail.com"}
        ]
      ]

      emails = CMS.get_possible_duplicates_from_people(people) |> Enum.map(& &1.email_address)

      assert Enum.member?(emails, "bob@gmail.com")
      assert Enum.member?(emails, "bib@gmail.com")
      assert Enum.member?(emails, "bobi@gmail.com")
      assert length(emails) === 3
    end

    test "get_possible_duplicates_from_people/1 same domain no duplicates return 0" do
      people = [
        [
          %Person{id: 1, email_address: "bob@gmail.com"},
          %Person{id: 2, email_address: "alex@gmail.com"},
          %Person{id: 3, email_address: "bibi@gmail.com"}
        ]
      ]

      emails = CMS.get_possible_duplicates_from_people(people) |> Enum.map(& &1.email_address)

      assert length(emails) === 0
    end

    test "get_possible_duplicates_from_people/1 same domain all duplicates same length return 3" do
      people = [
        [
          %Person{id: 1, email_address: "bob@gmail.com"},
          %Person{id: 2, email_address: "bib@gmail.com"},
          %Person{id: 3, email_address: "bpb@gmail.com"}
        ]
      ]

      emails = CMS.get_possible_duplicates_from_people(people) |> Enum.map(& &1.email_address)

      assert Enum.member?(emails, "bob@gmail.com")
      assert Enum.member?(emails, "bib@gmail.com")
      assert Enum.member?(emails, "bpb@gmail.com")
      assert length(emails) === 3
    end

    test "get_possible_duplicates_from_people/1 same domain two sets of duplicates" do
      people = [
        [
          %Person{id: 1, email_address: "bob@gmail.com"},
          %Person{id: 2, email_address: "bib@gmail.com"},
          %Person{id: 3, email_address: "alex@gmail.com"},
          %Person{id: 4, email_address: "akex@gmail.com"},
          %Person{id: 5, email_address: "cab@gmail.com"}
        ]
      ]

      emails = CMS.get_possible_duplicates_from_people(people) |> Enum.map(& &1.email_address)

      assert Enum.member?(emails, "bob@gmail.com")
      assert Enum.member?(emails, "bib@gmail.com")
      assert Enum.member?(emails, "alex@gmail.com")
      assert Enum.member?(emails, "akex@gmail.com")
      assert length(emails) === 4
    end

    test "get_possible_duplicates_from_people/1 same domain reversed string with one extra character" do
      people = [
        [
          %Person{id: 1, email_address: "alex@gmail.com"},
          %Person{id: 2, email_address: "xelai@gmail.com"}
        ]
      ]

      emails = CMS.get_possible_duplicates_from_people(people) |> Enum.map(& &1.email_address)

      assert length(emails) === 0
    end

    test "get_possible_duplicates_from_people/1 reversed string" do
      people = [
        [
          %Person{id: 1, email_address: "alex@gmail.com"},
          %Person{id: 2, email_address: "xela@gmail.com"}
        ]
      ]

      emails = CMS.get_possible_duplicates_from_people(people) |> Enum.map(& &1.email_address)

      assert length(emails) === 0
    end

    test "get_possible_duplicates_from_people/1 two chars difference" do
      people = [
        [
          %Person{id: 1, email_address: "alex@gmail.com"},
          %Person{id: 2, email_address: "alexis@gmail.com"}
        ]
      ]

      emails = CMS.get_possible_duplicates_from_people(people) |> Enum.map(& &1.email_address)

      assert length(emails) === 0
    end

    test "get_possible_duplicates_from_people/1 multiple domains" do
      people = [
        [
          %Person{id: 1, email_address: "alex@gmail.com"},
          %Person{id: 2, email_address: "alexi@gmail.com"}
        ],
        [
          %Person{id: 3, email_address: "kat@outlook.com"},
          %Person{id: 4, email_address: "kit@outlook.com"}
        ]
      ]

      emails = CMS.get_possible_duplicates_from_people(people) |> Enum.map(& &1.email_address)

      assert Enum.member?(emails, "alex@gmail.com")
      assert Enum.member?(emails, "alexi@gmail.com")
      assert Enum.member?(emails, "kat@outlook.com")
      assert Enum.member?(emails, "kit@outlook.com")
      assert length(emails) === 4
    end

    test "get_possible_duplicates_from_people/1 multiple domains one non duplicate email" do
      people = [
        [
          %Person{id: 1, email_address: "alex@gmail.com"},
          %Person{id: 2, email_address: "alexi@gmail.com"}
        ],
        [
          %Person{id: 3, email_address: "kat@outlook.com"},
          %Person{id: 4, email_address: "kit@outlook.com"},
          %Person{id: 5, email_address: "alice@outlook.com"}
        ]
      ]

      emails = CMS.get_possible_duplicates_from_people(people) |> Enum.map(& &1.email_address)

      assert Enum.member?(emails, "alex@gmail.com")
      assert Enum.member?(emails, "alexi@gmail.com")
      assert Enum.member?(emails, "kat@outlook.com")
      assert Enum.member?(emails, "kit@outlook.com")
      assert length(emails) === 4
    end

    test "get_possible_duplicates_from_people/1 multiple domains no duplicate" do
      people = [
        [
          %Person{id: 1, email_address: "alex@gmail.com"},
          %Person{id: 2, email_address: "alice@gmail.com"}
        ],
        [
          %Person{id: 3, email_address: "kat@outlook.com"},
          %Person{id: 4, email_address: "alice@outlook.com"}
        ]
      ]

      emails = CMS.get_possible_duplicates_from_people(people) |> Enum.map(& &1.email_address)

      assert length(emails) === 0
    end
  end

  describe "bucket people by domain" do
    test "bucket_people_by_domain/1 returns list of list of 2 people" do
      xyz = %Person{id: 1, email_address: "xyz@xyz.com"}
      abc = %Person{id: 2, email_address: "abc@abc.com"}
      buckets = CMS.bucket_people_by_domain([xyz, abc])
      expected = [[xyz], [abc]]

      assert MapSet.intersection(MapSet.new(buckets), MapSet.new(expected)) |> MapSet.size() ==
               length(buckets)
    end

    test "bucket_people_by_domain/1 returns list of list of multiple people" do
      xyz1 = %Person{id: 1, email_address: "xyz@xyz.com"}
      xyz2 = %Person{id: 1, email_address: "xyz2@xyz.com"}
      abc = %Person{id: 2, email_address: "abc1@abc.com"}
      buckets = CMS.bucket_people_by_domain([xyz1, abc, xyz2])
      expected = [[xyz1, xyz2], [abc]]

      assert MapSet.intersection(MapSet.new(buckets), MapSet.new(expected)) |> MapSet.size() ==
               length(buckets)
    end

    test "bucket_people_by_domain/1 returns empty list" do
      assert CMS.bucket_people_by_domain([]) == []
    end
  end
end
