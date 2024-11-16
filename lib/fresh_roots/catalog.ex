defmodule FreshRoots.Catalog do
  @moduledoc """
  The Catalog context.
  """

  alias FreshRoots.Repo
  alias FreshRoots.Product

  @doc """
  Returns the list of all products.

  ## Examples

    iex> list_products()
    [%Product{}]

  """
  @spec list_products() :: [Product.t()]
  def list_products do
    Repo.all(Product)
  end

  @doc """
  Gets a single product by its code.
  ## Examples

    iex> get_product_by_code("GR1")
    %Product{}


    iex> get_product_by_code("INVALID")
    nil

  """
  @spec get_product_by_code(String.t()) :: Product.t() | nil
  def get_product_by_code(code), do: Repo.get_by(Product, code: code)
end
