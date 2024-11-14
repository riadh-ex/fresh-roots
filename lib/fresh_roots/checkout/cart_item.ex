defmodule FreshRoots.Checkout.CartItem do
  @moduledoc """
  Represents a product in a shopping cart.
  """

  use Ecto.Schema

  @type t :: %__MODULE__{product: FreshRoots.Checkout.Product.t(), quantity: integer()}
  defstruct [:product, :quantity]
end
