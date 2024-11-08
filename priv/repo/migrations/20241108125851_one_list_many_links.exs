defmodule Bottich.Repo.Migrations.OneListManyLinks do
  use Ecto.Migration

  def change do
    alter table(:links) do
      add :list_id, references(:lists)
    end
  end
end
