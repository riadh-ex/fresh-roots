defmodule FreshRootsWeb.Components do
  @moduledoc """
  Components for the FreshRootsWeb application.
  """

  use FreshRootsWeb, :component

  import FreshRootsWeb.Components.Helpers

  def product(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow-md overflow-hidden">
      <img src={@product.image_path} class="w-full h-60 object-cover" />
      <div class="p-4">
        <h2 class="text-xl font-semibold mb-2"><%= @product.name %></h2>
        <div class="flex justify-between items-center">
          <span class="text-lg font-bold">
            £<%= pence_to_pounds_format(@product.price_unit_amount) %>
          </span>
          <button
            phx-click="add_to_cart"
            phx-value-id={@product.code}
            class="bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded"
          >
            <%= gettext("Add to Cart") %>
          </button>
        </div>
      </div>
    </div>
    """
  end
end
