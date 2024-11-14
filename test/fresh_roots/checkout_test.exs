defmodule FreshRoots.CheckoutTest do
  use FreshRoots.DataCase

  alias FreshRoots.Checkout
  alias FreshRoots.Checkout.Cart

  @green_tea_code "GR1"
  @strawberries_code "SR1"
  @coffee_code "CF1"

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

  describe "add_to_cart/3" do
    test "correctly adds products to the cart" do
      cart = Checkout.new_cart()

      {:ok, cart} = Checkout.add_to_cart(cart, @green_tea_code)

      assert %Cart{items: [%Checkout.CartItem{product: %{code: @green_tea_code}, quantity: 1}]} =
               cart

      {:ok, cart} = Checkout.add_to_cart(cart, @green_tea_code)

      assert %Cart{items: [%Checkout.CartItem{product: %{code: @green_tea_code}, quantity: 2}]} =
               cart

      {:ok, cart} = Checkout.add_to_cart(cart, @strawberries_code)

      assert %Cart{
               items: [
                 %Checkout.CartItem{product: %{code: @strawberries_code}, quantity: 1},
                 %Checkout.CartItem{product: %{code: @green_tea_code}, quantity: 2}
               ]
             } = cart
    end
  end

  describe "cart_total/1" do
    test "returns the total price of the cart" do
      cart = Checkout.new_cart()

      {:ok, cart} = Checkout.add_to_cart(cart, @green_tea_code)
      {:ok, cart} = Checkout.add_to_cart(cart, @strawberries_code)
      {:ok, cart} = Checkout.add_to_cart(cart, @coffee_code)

      assert Checkout.cart_total(cart) == 1934
    end

    test "returns the correct price of the cart with the CEO discount" do
      cart = Checkout.new_cart()

      {:ok, cart} = Checkout.add_to_cart(cart, @green_tea_code)

      assert Checkout.cart_total(cart) == 311

      {:ok, cart} = Checkout.add_to_cart(cart, @green_tea_code)

      # The second green tea should be free
      assert Checkout.cart_total(cart) == 311

      {:ok, cart} = Checkout.add_to_cart(cart, @green_tea_code)

      assert Checkout.cart_total(cart) == 622

      {:ok, cart} = Checkout.add_to_cart(cart, @green_tea_code)

      # The fourth green tea should be free
      assert Checkout.cart_total(cart) == 622
    end

    test "returns the correct price of the cart with the COO discount" do
      cart = Checkout.new_cart()

      {:ok, cart} = Checkout.add_to_cart(cart, @strawberries_code)

      assert Checkout.cart_total(cart) == 500

      {:ok, cart} = Checkout.add_to_cart(cart, @strawberries_code)

      assert Checkout.cart_total(cart) == 1000

      {:ok, cart} = Checkout.add_to_cart(cart, @strawberries_code)

      # Price should drop to 4.50 per unit after the third strawberry
      assert Checkout.cart_total(cart) == 1350

      {:ok, cart} = Checkout.add_to_cart(cart, @strawberries_code)

      assert Checkout.cart_total(cart) == 1800
    end
  end
end
