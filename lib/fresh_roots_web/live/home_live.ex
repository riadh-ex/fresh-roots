defmodule FreshRootsWeb.HomeLive do
  use FreshRootsWeb, :live_view

  alias FreshRoots.{Catalog, Checkout}
  import FreshRootsWeb.Components.Helpers

  @impl true
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

    <div class="fixed top-16 right-0 lg:right-8 w-full max-w-xs lg:max-w-sm mt-8 lg:mt-0">
      <div class="bg-white rounded-lg shadow-md p-4 lg:p-6">
        <h2 class="text-xl font-bold mb-4">Your Cart</h2>
        <div class="space-y-4">
          <%= for %{product: product, quantity: quantity} <- @cart.items do %>
            <div class="flex justify-between items-center">
              <span><%= product.name %> (x<%= quantity %>)</span>
            </div>
          <% end %>
        </div>
        <div class="mt-4 pt-4 border-t">
          <div class="flex justify-between items-center">
            <span><%= gettext("Subtotal") %>:</span>
            <span>£<%= pence_to_pounds_format(Checkout.cart_total(@cart).subtotal) %></span>
          </div>
          <div class="flex justify-between items-center text-red-500">
            <span><%= gettext("Discount") %>:</span>
            <span>-£<%= pence_to_pounds_format(Checkout.cart_total(@cart).discount) %></span>
          </div>
          <div class="flex justify-between items-center font-bold border-t mt-2 pt-2">
            <span><%= gettext("Total") %>:</span>
            <span>£<%= pence_to_pounds_format(Checkout.cart_total(@cart).total) %></span>
          </div>
        </div>
        <button
          phx-click="checkout"
          class="w-full mt-4 bg-green-500 hover:bg-green-600 text-white font-bold py-2 px-4 rounded"
        >
          <%= gettext("Checkout") %>
        </button>
        <button
          phx-click="clear_cart"
          class="w-full mt-2 bg-gray-200 hover:bg-gray-300 text-gray-700 font-bold py-2 px-4 rounded"
        >
          <%= gettext("Clear") %>
        </button>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("add_to_cart", %{"id" => product_code}, %{assigns: %{cart: cart}} = socket) do
    case Checkout.add_to_cart(cart, product_code) do
      {:ok, updated_cart} ->
        {:noreply, assign(socket, cart: updated_cart)}

      {:error, :not_found} ->
        # Potential improvement is to show a flash message in this case
        {:noreply, socket}
    end
  end

  def handle_event("clear_cart", _, socket),
    do: {:noreply, assign(socket, cart: Checkout.new_cart())}

  def handle_event("checkout", _, %{assigns: %{cart: cart}} = socket) do
    # Move to the payment page or the next step in the checkout process
    # but for now show a success flash message and clear the cart.

    socket =
      case cart.items do
        [] ->
          put_flash(socket, :error, gettext("Cart is empty!"))

        _ ->
          socket
          |> put_flash(
            :info,
            gettext("Checkout successful! Do come back soon when payment is implemented!")
          )
          |> assign(cart: Checkout.new_cart())
      end

    {:noreply, socket}
  end

  @impl true
  def mount(_params, _session, socket) do
    products = Catalog.list_products()
    cart = Checkout.new_cart()

    {:ok, assign(socket, products: products, cart: cart)}
  end
end
