defmodule Bottich.BottichLists.List do
  alias Bottich.BottichLink
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :name, :string
    field :description, :string
    has_many :links, BottichLink.Link
    belongs_to :users, Bottich.Accounts.User, foreign_key: :user_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:name, :description, :user_id])
    |> validate_required([:name, :description, :user_id])
  end
end
