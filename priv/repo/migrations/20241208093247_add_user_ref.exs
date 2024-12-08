defmodule Bottich.Repo.Migrations.AddUserRef do
  use Ecto.Migration

  def change do
    alter table(:lists) do
      add :user, references(:users, on_delete: :delete_all)
    end

    drop constraint("links", "links_list_id_fkey")

    alter table(:links) do
      modify :list_id,
             references(:lists, on_delete: :delete_all)
    end
  end
end
