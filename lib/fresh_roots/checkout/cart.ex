defmodule FreshRoots.Checkout.Cart do
  @moduledoc """
  Represents a shopping cart in the FreshRoots checkout system.

  Currently, the cart is stored in-memory, allowing customers to add, update,
  or remove items. In the future, we may add persistence to maintain cart state
  between sessions.
  """

  @type t :: %__MODULE__{items: [FreshRoots.Checkout.CartItem.t()]}
  defstruct [:items]
end
