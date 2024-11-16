defmodule FreshRoots.CheckoutTest do
  use FreshRoots.DataCase

  alias FreshRoots.Checkout
  alias FreshRoots.Checkout.Cart

  @green_tea_code "GR1"
  @strawberries_code "SR1"
  @coffee_code "CF1"

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

      assert %{total: 1934} = Checkout.cart_total(cart)
    end

    test "returns the correct price of the cart with the CEO discount - Buy one get one free discount" do
      cart = Checkout.new_cart()

      {:ok, cart} = Checkout.add_to_cart(cart, @green_tea_code)

      assert %{total: 311} = Checkout.cart_total(cart)

      {:ok, cart} = Checkout.add_to_cart(cart, @green_tea_code)

      # The second green tea should be free
      assert %{total: 311} = Checkout.cart_total(cart)

      {:ok, cart} = Checkout.add_to_cart(cart, @green_tea_code)

      assert %{total: 622} = Checkout.cart_total(cart)

      {:ok, cart} = Checkout.add_to_cart(cart, @green_tea_code)

      # The fourth green tea should be free
      assert %{total: 622} = Checkout.cart_total(cart)
    end

    test "returns the correct price of the cart with the COO discount - Bulk price drop discount" do
      cart = Checkout.new_cart()

      {:ok, cart} = Checkout.add_to_cart(cart, @strawberries_code)

      assert %{total: 500} = Checkout.cart_total(cart)

      {:ok, cart} = Checkout.add_to_cart(cart, @strawberries_code)

      assert %{total: 1000} = Checkout.cart_total(cart)

      {:ok, cart} = Checkout.add_to_cart(cart, @strawberries_code)

      # Price should drop to 4.50 per unit after the third strawberry
      assert %{total: 1350} = Checkout.cart_total(cart)

      {:ok, cart} = Checkout.add_to_cart(cart, @strawberries_code)

      assert %{total: 1800} = Checkout.cart_total(cart)
    end

    test "returns the correct price of the cart with the CTO discount - Fractional discount" do
      cart = Checkout.new_cart()

      {:ok, cart} = Checkout.add_to_cart(cart, @coffee_code)

      assert %{total: 1123} = Checkout.cart_total(cart)

      {:ok, cart} = Checkout.add_to_cart(cart, @coffee_code)

      assert %{total: 2246} = Checkout.cart_total(cart)

      {:ok, cart} = Checkout.add_to_cart(cart, @coffee_code)

      # Price should drop to 2/3 of the original price after the third coffee
      assert %{total: 2246} = Checkout.cart_total(cart)

      {:ok, cart} = Checkout.add_to_cart(cart, @coffee_code)

      assert %{total: 2995} = Checkout.cart_total(cart)
    end
  end

  describe "validation tests for the provided test data" do
    @test_data [
      %{
        items: ["GR1", "SR1", "GR1", "GR1", "CF1"],
        expected_total: 2245
      },
      %{
        items: ["GR1", "GR1"],
        expected_total: 311
      },
      %{
        items: ["SR1", "SR1", "GR1", "SR1"],
        expected_total: 1661
      },
      %{
        items: ["GR1", "CF1", "SR1", "CF1", "CF1"],
        expected_total: 3057
      }
    ]

    Enum.each(@test_data, fn %{items: items, expected_total: expected_total} ->
      test "returns correct total for test data #{inspect(items)}, expecting: #{expected_total}" do
        cart = Checkout.new_cart()

        cart =
          Enum.reduce(unquote(items), cart, fn item, acc ->
            {:ok, acc} = Checkout.add_to_cart(acc, item)
            acc
          end)

        assert %{total: unquote(expected_total)} = Checkout.cart_total(cart)
      end
    end)
  end
end
