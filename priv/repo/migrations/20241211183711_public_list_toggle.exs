defmodule Bottich.Repo.Migrations.PublicListToggle do
  use Ecto.Migration

  def change do
    alter table(:lists) do
      add :public, :boolean, default: false
    end
  end
end
