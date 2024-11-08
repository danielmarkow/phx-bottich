defmodule Bottich.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :link, :string
      add :description, :text

      timestamps(type: :utc_datetime)
    end
  end
end
