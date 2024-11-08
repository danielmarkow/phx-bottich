defmodule Bottich.BottichLinkFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bottich.BottichLink` context.
  """

  @doc """
  Generate a link.
  """
  def link_fixture(attrs \\ %{}) do
    {:ok, link} =
      attrs
      |> Enum.into(%{
        description: "some description",
        link: "some link"
      })
      |> Bottich.BottichLink.create_link()

    link
  end
end
