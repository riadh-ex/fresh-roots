defmodule FreshRoots.Checkout do
  @moduledoc """
  The Checkout context.
  """

  import Ecto.Query, warn: false
  alias FreshRoots.Repo

  alias FreshRoots.Checkout.Product

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
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)
end
