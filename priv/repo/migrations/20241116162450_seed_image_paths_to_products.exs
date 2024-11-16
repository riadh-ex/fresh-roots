defmodule FreshRoots.Repo.Migrations.SeedImagePathsToProducts do
  use Ecto.Migration

  alias FreshRoots.Repo

  alias Ecto.Changeset
  import Ecto.Query, warn: false

  @disable_ddl_transaction true

  # This migration is for demo purposes only, it is not a good practice to
  # update records this way in a production environment.
  def change do
    FreshRoots.Repo.all(FreshRoots.Product)
    |> Enum.map(fn product ->
      case product.code do
        "GR1" -> Changeset.change(product, %{image_path: "/images/green_tea.jpg"})
        "SR1" -> Changeset.change(product, %{image_path: "/images/strawberries.jpg"})
        "CF1" -> Changeset.change(product, %{image_path: "/images/coffee.jpg"})
        _ -> product
      end
    end)
    |> Enum.each(&Repo.update/1)
  end
end
