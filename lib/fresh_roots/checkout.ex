defmodule FreshRoots.Checkout do
  @moduledoc """
  The Checkout context.
  """

  alias FreshRoots.Checkout.{Cart, CartItem, Discount}
  alias FreshRoots.Catalog

  @doc """
  Returns a new, empty cart.

  ## Examples

    iex> new_cart()
    %Cart{items: []}

  """
  @spec new_cart() :: Cart.t()
  def new_cart, do: %Cart{items: []}

  @doc """
  Adds a product to the cart.

  If the product is not found, it returns `{:error, :not_found}`.

  ## Parameters
  - `cart` - the cart to which the product will be added
  - `product_code` - the code of the product to add
  - `quantity` - the quantity of the product to add, defaults to 1

  ## Examples

    iex> cart = new_cart()
    iex> add_to_cart(cart, "GR1")
    {:ok, %Cart{items: [%CartItem{product: %Product{}, quantity: 1}]}}
  """
  @spec add_to_cart(Cart.t(), String.t(), integer()) :: {:ok, Cart.t()} | {:error, :not_found}
  def add_to_cart(cart, product_code, quantity \\ 1) do
    case Catalog.get_product_by_code(product_code) do
      nil ->
        {:error, :not_found}

      product ->
        case Enum.find_index(cart.items, &(&1.product.code == product_code)) do
          nil ->
            new_item = %CartItem{product: product, quantity: quantity}
            updated_cart = %Cart{items: [new_item | cart.items]}
            {:ok, updated_cart}

          index ->
            updated_cart =
              update_in(
                cart,
                [Access.key(:items), Access.at(index), Access.key(:quantity)],
                &(&1 + quantity)
              )

            {:ok, updated_cart}
        end
    end
  end

  # The purpose of making discounts declarative is to make it easier to change
  # the rules in the future, persist them in the database, or even apply custom
  # discounts for specific customers.
  @discount_rules [
    Discount.buy_one_get_one_free("GR1"),
    Discount.bulk_purchase_price_drop("SR1", 450, 3),
    Discount.fractional_discount("CF1", 3, 3)
  ]

  @spec cart_total(Cart.t()) :: %{total: integer(), subtotal: integer(), discount: integer()}
  def cart_total(%Cart{items: items}) do
    total_without_discount =
      Stream.map(items, &(&1.product.price_unit_amount * &1.quantity))
      |> Enum.sum()

    total_discount = Discount.total_discount(items, @discount_rules)

    %{
      total: total_without_discount - total_discount,
      subtotal: total_without_discount,
      discount: total_discount
    }
  end
end
