defmodule FreshRoots.Checkout.Discount do
  @moduledoc """
  The Discount module provides functions to calculate discounts on cart items.
  """
  alias FreshRoots.Checkout.CartItem

  defmodule Rule do
    @moduledoc """
    Represents a discount rule._It's not intended to be used directly, but through the functions in the `Discount` module._
    """

    @type t :: %__MODULE__{
            product_code: String.t(),
            type: :buy_one_get_one_free | :bulk_purchase_price_drop | :fractional_discount,
            meta:
              %{new_price: integer(), price_drop_quantity: integer()}
              | %{price_drop_quantity: integer(), fraction: integer()}
              | %{}
          }

    defstruct [:product_code, :type, meta: %{}]
  end

  @doc """
    Calculates the total discount for a list of cart items based on a list of discount rules.

    ## Parameters
    - `cart_items` - a list of cart items
    - `discount_rules` - a list of discount rules

    ## Examples

      iex> alias FreshRoots.Checkout.{CartItem, Discount}
      iex> cart_items = [
      ...>   %CartItem{product: %FreshRoots.Product{code: "GR1", price_unit_amount: 311}, quantity: 1},
      ...>   %CartItem{product: %FreshRoots.Product{code: "SR1", price_unit_amount: 500}, quantity: 1},
      ...>   %CartItem{product: %FreshRoots.Product{code: "CF1", price_unit_amount: 1123}, quantity: 3}
      ...> ]
      iex> discount_rules = [
      ...>   Discount.buy_one_get_one_free("GR1"),
      ...>   Discount.bulk_purchase_price_drop("SR1", 450, 3),
      ...>   Discount.fractional_discount("CF1", 3, 3)
      ...> ]
      iex> Discount.total_discount(cart_items, discount_rules)

      3057
  """
  @spec total_discount([CartItem.t()], [Rule.t()]) :: integer()
  def total_discount(cart_items, discount_rules) do
    discount_rules
    |> Stream.map(&apply_discount(cart_items, &1))
    |> Enum.sum()
  end

  @doc ~S"""
  Creates a discount rule for a buy-one-get-one-free offer.

  ## Parameters
  - `product_code` - the product code for which the discount applies

  ## Examples

    iex> FreshRoots.Checkout.Discount.buy_one_get_one_free("GR1")

    %FreshRoots.Checkout.Discount.Rule{
      product_code: "GR1",
      type: :buy_one_get_one_free,
      meta: %{}
    }

  """

  @spec buy_one_get_one_free(String.t()) :: Rule.t()
  def buy_one_get_one_free(product_code),
    do: %Rule{product_code: product_code, type: :buy_one_get_one_free}

  @doc """
  Creates a discount rule for a bulk purchase price drop offer.

  ## Parameters
  - `product_code` - the product code for which the discount applies
  - `new_price` - the new price for the product
  - `price_drop_quantity` - the quantity at which the price drops, strictly greater than 0

  ## Examples

    iex> FreshRoots.Checkout.Discount.bulk_purchase_price_drop("SR1", 450, 3)

    %FreshRoots.Checkout.Discount.Rule{
      product_code: "SR1",
      type: :bulk_purchase_price_drop,
      meta: %{new_price: 450, price_drop_quantity: 3}
    }

  """
  @spec bulk_purchase_price_drop(String.t(), integer(), integer()) :: Rule.t()
  def bulk_purchase_price_drop(product_code, new_price, price_drop_quantity),
    do: %Rule{
      product_code: product_code,
      type: :bulk_purchase_price_drop,
      meta: %{new_price: new_price, price_drop_quantity: price_drop_quantity}
    }

  @doc """
  Creates a discount rule for a fractional discount offer.

  ## Parameters
  - `product_code` - the product code for which the discount applies
  - `price_drop_quantity` - the quantity at which the price drops, strictly greater than 0
  - `fraction` - the fraction of the price to be discounted, strictly greater than 0

  ## Examples

    iex> FreshRoots.Checkout.Discount.fractional_discount("CF1", 3, 3)

    %FreshRoots.Checkout.Discount.Rule{
      product_code: "CF1",
      type: :fractional_discount,
      meta: %{fraction: 3, price_drop_quantity: 3}
    }
  """

  @spec fractional_discount(String.t(), integer(), integer()) :: Rule.t()
  def fractional_discount(product_code, price_drop_quantity, fraction),
    do: %Rule{
      product_code: product_code,
      type: :fractional_discount,
      meta: %{price_drop_quantity: price_drop_quantity, fraction: fraction}
    }

  defp apply_discount(cart_items, %Rule{type: :buy_one_get_one_free, product_code: product_code}) do
    case find_cart_item(cart_items, product_code) do
      %CartItem{product: product, quantity: quantity} when quantity >= 2 ->
        div(quantity, 2) * product.price_unit_amount

      _ ->
        0
    end
  end

  defp apply_discount(
         cart_items,
         %Rule{
           type: :bulk_purchase_price_drop,
           product_code: product_code,
           meta: %{new_price: new_price, price_drop_quantity: price_drop_quantity}
         }
       ) do
    case find_cart_item(cart_items, product_code) do
      %CartItem{product: product, quantity: quantity} when quantity >= price_drop_quantity ->
        quantity * (product.price_unit_amount - new_price)

      _ ->
        0
    end
  end

  defp apply_discount(
         cart_items,
         %Rule{
           type: :fractional_discount,
           product_code: product_code,
           meta: %{price_drop_quantity: price_drop_quantity, fraction: fraction}
         }
       ) do
    case find_cart_item(cart_items, product_code) do
      %CartItem{product: product, quantity: quantity} when quantity >= price_drop_quantity ->
        div(quantity * product.price_unit_amount, fraction)

      _ ->
        0
    end
  end

  defp find_cart_item(cart_items, product_code) do
    Enum.find(cart_items, &(&1.product.code == product_code))
  end
end
