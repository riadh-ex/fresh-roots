defmodule FreshRoots.Repo.Migrations.SeedProducts do
  use Ecto.Migration

  alias FreshRoots.Product
  alias FreshRoots.Repo

  import Ecto.Query, warn: false

  @disable_ddl_transaction true

  @products [
    %{
      code: "GR1",
      name: "Green tea",
      price_unit_amount: 311
    },
    %{
      code: "SR1",
      name: "Strawberries",
      price_unit_amount: 500
    },
    %{
      code: "CF1",
      name: "Coffee",
      price_unit_amount: 1123
    }
  ]

  def up do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    products = Enum.map(@products, &Map.merge(&1, %{inserted_at: now, updated_at: now}))

    Repo.insert_all(Product, products)
  end

  def down do
    from(p in Product, where: p.code in ^Enum.map(@products, & &1.code))
    |> Repo.delete_all()
  end
end
