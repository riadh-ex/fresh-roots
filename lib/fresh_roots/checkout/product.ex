defmodule FreshRoots.Checkout.Product do
  @moduledoc """
  Represents a product in our little supermarket.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          code: String.t(),
          name: String.t(),
          price_unit_amount: integer(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "products" do
    field :code, :string
    field :name, :string

    # This field represents the price of a single unit of the product in pence.
    # It's sufficient for proper calculations and avoiding floating-point errors,
    # but on a second iteration where we'd like to support multiple currencies
    # and more complex features, we should definitely consider using the
    # ex_money library. https://hexdocs.pm/ex_money
    field :price_unit_amount, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:code, :name, :price_unit_amount])
    |> validate_required([:code, :name, :price_unit_amount])
  end
end
