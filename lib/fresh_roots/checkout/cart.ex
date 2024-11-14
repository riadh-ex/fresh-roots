defmodule FreshRoots.Checkout.Cart do
  use Ecto.Schema

  @type t :: %__MODULE__{items: [FreshRoots.Checkout.CartItem.t()]}
  defstruct [:items]
end
