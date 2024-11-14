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

  def add_to_cart(cart, product_code, quantity \\ 1) do
    case get_product_by_code(product_code) do
      nil ->
        {:error, :not_found}

      product ->
        case Enum.find_index(cart.items, &(&1.product.code == product_code)) do
          nil ->
            item = %CartItem{product: product, quantity: quantity}
            items = [item | cart.items]
            cart = %Cart{items: items}
            {:ok, cart}

          index ->
            item = cart.items |> Enum.at(index)
            new_quantity = item.quantity + quantity
            new_item = %{item | quantity: new_quantity}
            items = cart.items |> List.replace_at(index, new_item)
            cart = %Cart{items: items}
            {:ok, cart}
        end
    end
  end
end
