defmodule FreshRoots.Repo.Migrations.AddImagePathToProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :image_path, :string
    end
  end
end
