defmodule Bottich.Repo.Migrations.RenameRef do
  use Ecto.Migration

  def change do
    rename table(:lists), :user, to: :user_id
  end
end
