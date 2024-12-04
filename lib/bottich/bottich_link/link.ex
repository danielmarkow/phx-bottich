defmodule Bottich.BottichLink.Link do
  alias Bottich.BottichLists
  use Ecto.Schema
  import Ecto.Changeset

  schema "links" do
    field :link, :string
    field :description, :string
    belongs_to :list, BottichLists.List

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:link, :description])
    |> validate_required([:link, :description])
  end
end
