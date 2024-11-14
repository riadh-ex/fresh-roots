defmodule FreshRoots.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :code, :string
      add :name, :string
      add :price_unit_amount, :integer

      timestamps(type: :utc_datetime)
    end

    create unique_index(:products, [:code])
  end
end
