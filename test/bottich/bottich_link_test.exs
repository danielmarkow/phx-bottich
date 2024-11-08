defmodule Bottich.BottichLinkTest do
  use Bottich.DataCase

  alias Bottich.BottichLink

  describe "links" do
    alias Bottich.BottichLink.Link

    import Bottich.BottichLinkFixtures

    @invalid_attrs %{link: nil, description: nil}

    test "list_links/0 returns all links" do
      link = link_fixture()
      assert BottichLink.list_links() == [link]
    end

    test "get_link!/1 returns the link with given id" do
      link = link_fixture()
      assert BottichLink.get_link!(link.id) == link
    end

    test "create_link/1 with valid data creates a link" do
      valid_attrs = %{link: "some link", description: "some description"}

      assert {:ok, %Link{} = link} = BottichLink.create_link(valid_attrs)
      assert link.link == "some link"
      assert link.description == "some description"
    end

    test "create_link/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BottichLink.create_link(@invalid_attrs)
    end

    test "update_link/2 with valid data updates the link" do
      link = link_fixture()
      update_attrs = %{link: "some updated link", description: "some updated description"}

      assert {:ok, %Link{} = link} = BottichLink.update_link(link, update_attrs)
      assert link.link == "some updated link"
      assert link.description == "some updated description"
    end

    test "update_link/2 with invalid data returns error changeset" do
      link = link_fixture()
      assert {:error, %Ecto.Changeset{}} = BottichLink.update_link(link, @invalid_attrs)
      assert link == BottichLink.get_link!(link.id)
    end

    test "delete_link/1 deletes the link" do
      link = link_fixture()
      assert {:ok, %Link{}} = BottichLink.delete_link(link)
      assert_raise Ecto.NoResultsError, fn -> BottichLink.get_link!(link.id) end
    end

    test "change_link/1 returns a link changeset" do
      link = link_fixture()
      assert %Ecto.Changeset{} = BottichLink.change_link(link)
    end
  end
end
