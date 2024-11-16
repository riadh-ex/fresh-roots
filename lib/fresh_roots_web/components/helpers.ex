defmodule FreshRootsWeb.Components.Helpers do
  @moduledoc """
  Helper functions for components.
  """

  @doc """
  Converts a price in pence to a string formatted as pounds.
  """
  @spec pence_to_pounds_format(integer()) :: String.t()
  def pence_to_pounds_format(pence) do
    pounds = Decimal.div(pence, 100)
    Decimal.to_string(pounds)
  end
end
