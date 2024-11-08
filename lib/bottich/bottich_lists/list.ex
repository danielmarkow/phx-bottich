defmodule Bottich.BottichLists.List do
  alias Bottich.BottichLink
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :name, :string
    field :description, :string
    has_many :links, BottichLink.Link

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
