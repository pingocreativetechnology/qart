defmodule QartWeb.ItemLive.Show do
  use QartWeb, :live_view

  alias Qart.Inventory
  alias Qart.Favorites

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, payment_request: false)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    user = socket.assigns[:current_user]
    is_favorited = if user, do: Favorites.is_favorited?(user.id, id), else: false

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:item, Inventory.get_item!(id))
     |> assign(:is_favorited, is_favorited)
    }
  end

  @impl true
  def handle_params(%{"id" => item_id}, _uri, socket) do
    user_id = socket.assigns.current_user.id
    is_favorited = Favorites.is_favorited?(user_id, item_id)

    {:noreply, assign(socket, item_id: String.to_integer(item_id), is_favorited: is_favorited)}
  end

  @impl true
  def handle_event("toggle_favorite", %{"value" => item_id}, socket) do
    user_id = socket.assigns.current_user.id

    if socket.assigns.is_favorited do
      Favorites.unfavorite_item(user_id, item_id)
      {:noreply, assign(socket, is_favorited: false)}
    else
      Favorites.favorite_item(user_id, item_id)
      {:noreply, assign(socket, is_favorited: true)}
    end
  end

  @impl true
  def handle_event("buy_now", %{"value" => item_id}, socket) do
    # payment_address = "Payments.generate_payment_request()"
    payment_address = "1J12o2k964mJPTuS53Un7oJ2Hxo5ksYf4L"
    {:noreply, assign(socket, payment_request: "true",
      payment_address: payment_address)
    }
  end

  defp page_title(:show), do: "Show Item"
  defp page_title(:edit), do: "Edit Item"
end
