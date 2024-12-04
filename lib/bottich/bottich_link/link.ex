defmodule Bottich.BottichLink.Link do
  alias Bottich.BottichLists
  use Ecto.Schema
  import Ecto.Changeset

  schema "links" do
    field :url, :string
    field :description, :string
    belongs_to :lists, BottichLists.List, foreign_key: :list_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:url, :description])
    |> validate_required([:url, :description])
    |> validate_format(:url, ~r/^https?:\/\//, message: "must start with http:// or https://")
    |> validate_length(:url, max: 255)
    |> validate_length(:description, max: 2000)
    |> assoc_constraint(:lists)
  end
end
