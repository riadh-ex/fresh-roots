defmodule FreshRoots.CheckoutTest do
  use FreshRoots.DataCase

  alias FreshRoots.Checkout

  describe "list_products/0" do
    test "returns all products" do
      assert Checkout.list_products() |> length() == 3
    end
  end

  describe "new_cart/0" do
    test "returns an empty cart" do
      assert %Checkout.Cart{items: []} = Checkout.new_cart()
    end
  end
end
