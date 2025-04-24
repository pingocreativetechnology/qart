defmodule QartWeb.CartLive do
  use QartWeb, :live_view

  alias Qart.Shopping

  @impl true
  def mount(_params, session, socket) do
    user_id = if socket.assigns.current_user,
      do: socket.assigns.current_user.id,
      else: nil

    cart_items = Shopping.get_cart_items(user_id)
    cart = Shopping.get_or_create_cart(user_id)
    cart_total = Shopping.get_cart_total(cart.id)

    {:ok, assign(socket,
      cart: cart,
      cart_items: cart_items,
      cart_total: cart_total,
      invoice_line_items: [],
      user_id: user_id,
      checkout: false
    )}
  end

  @impl true
  def handle_event("add_item", %{"item_id" => item_id}, socket) do
    Shopping.add_to_cart(socket.assigns.user_id, item_id)
    {:noreply, assign(socket, cart_items: Shopping.get_cart_items(socket.assigns.user_id))}
  end

  @impl true
  def handle_event("checkout", _, socket) do
    %{payees: payees} = Shopping.get_cart_total(socket.assigns.cart.id)

    {:noreply, assign(socket,
      cart_items: Shopping.get_cart_items(socket.assigns.user_id),
      checkout: true,
      payees: payees,
      transaction_id: 123243443
    )}
  end

  def handle_event("remove_from_cart", %{"item_id" => item_id}, socket) do
    case Shopping.remove_from_cart(socket.assigns.current_user.id, item_id) do
      {:ok, _cart_item_id} ->
        socket = socket
          |> put_flash(:info, "Item removed from cart")
          |> assign(cart_items: Shopping.get_cart_items(socket.assigns.user_id))
          |> assign(item_in_cart: false)
          |> assign(cart_total: Shopping.get_cart_total(socket.assigns.cart.id))

        {:noreply, socket}

      {:error, :not_in_cart} ->
        {:noreply, put_flash(socket, :error, "Item was not in your cart")}
    end
  end

  def handle_event("empty_cart", _params, socket) do
    Shopping.empty_cart(socket.assigns.user_id)

    socket = socket
      |> put_flash(:info, "Cart emptied")
      |> assign(cart_total: Shopping.get_cart_total(socket.assigns.cart.id))

    {:noreply, assign(socket, cart_items: [])}
  end

end
