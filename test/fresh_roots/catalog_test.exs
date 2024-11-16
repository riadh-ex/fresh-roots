defmodule FreshRoots.CatalogTest do
  use FreshRoots.DataCase

  alias FreshRoots.Catalog

  describe "list_products/0" do
    test "returns all products" do
      assert Catalog.list_products() |> length() == 3
    end
  end
end
