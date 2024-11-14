defmodule FreshRoots.Checkout do
  @moduledoc """
  The Checkout context.
  """

  import Ecto.Query, warn: false
  alias FreshRoots.Repo

  alias FreshRoots.Checkout.{Cart, CartItem, Product}

  @doc """
  Returns the list of all products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """

  def list_products do
    # If this was a larger app it might be better to move this to a separate `Catalog`
    # context to keep the Checkout context focused on the checkout process.
    Repo.all(Product)
  end

  @doc """
  Gets a single product by its code.
  ## Examples

      iex> get_product_by_code("GR1")
      {:ok, %Product{}}


      iex> get_product_by_code("INVALID")
      nil

  """
  def get_product_by_code(code), do: Repo.get_by(Product, code: code)

  @doc """
  Returns a new, empty cart.

  ## Examples

      iex> new_cart()
      %Cart{products: []}

  """
  def new_cart, do: %Cart{items: []}

  @doc """
  Adds a product to the cart.

  If the product is not found, it returns `{:error, :not_found}`.

  ## Examples

      iex> cart = new_cart()
      iex> add_to_cart(cart, "GR1")
      {:ok, %Cart{items: [%CartItem{product: %Product{}, quantity: 1}]}}
  """
  def add_to_cart(cart, product_code, quantity \\ 1) do
    case get_product_by_code(product_code) do
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

  def cart_total(%Cart{items: items}) do
    Stream.map(items, &(&1.product.price_unit_amount * &1.quantity)) |> Enum.sum()
  end
end
