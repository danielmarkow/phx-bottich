defmodule Bottich.Repo.Migrations.RenameLinkCol do
  use Ecto.Migration

  def change do
    rename table(:links), :link, to: :url
  end
end
