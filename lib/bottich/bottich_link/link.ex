defmodule Bottich.BottichLink.Link do
  use Ecto.Schema
  import Ecto.Changeset

  schema "links" do
    field :link, :string
    field :description, :string
    field :list_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(link, attrs) do
    link
    |> cast(attrs, [:link, :description])
    |> validate_required([:link, :description])
  end
end
