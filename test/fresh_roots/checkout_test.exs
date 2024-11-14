defmodule FreshRoots.CheckoutTest do
  use FreshRoots.DataCase

  alias FreshRoots.Checkout

  describe "list_products/0" do
    test "returns all products" do
      assert Checkout.list_products() |> length() == 3
    end
  end
end
