defmodule Bottich.BottichListsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bottich.BottichLists` context.
  """

  @doc """
  Generate a list.
  """
  def list_fixture(attrs \\ %{}) do
    {:ok, list} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> Bottich.BottichLists.create_list()

    list
  end
end
