defmodule FreshRootsWeb.HomeLive do
  use FreshRootsWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-6">
        <%= gettext("Welcome to Fresh Roots") %>
      </h1>

      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
        <%= for product <- @products do %>
          <FreshRootsWeb.Components.product product={product} />
        <% end %>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    products = FreshRoots.Checkout.list_products()
    {:ok, assign(socket, products: products)}
  end
end
