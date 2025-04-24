defmodule QartWeb.ItemLive.Show do
  use QartWeb, :live_view

  import Qart.Utils

  alias Qart.Inventory
  alias Qart.Favorites
  alias Qart.Shopping

  @impl true
  def mount(_params, %{}, socket) do

    {:ok, assign(socket,
      payment_request: false,
      payment_request_qr_code_url: nil,
      handcash_client: nil
    )}
  end

  # Handcash
  def mount(_params, %{"handcash_oauth_token" => handcash_oauth_token} = _session, socket) do
    handcash_client = Handkit.create_connect_client(handcash_oauth_token)

    {:ok, assign(socket,
      payment_request: false,
      payment_request_qr_code_url: nil,
      handcash_client: handcash_client,
      item_in_cart: nil
    )}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    user = socket.assigns.current_user

    is_favorited = if user, do: Favorites.is_favorited?(user.id, id), else: false
    item = Inventory.get_item!(id)

    case user do
      %Qart.Accounts.User{} ->

        cart = Shopping.get_or_create_cart(user.id)
        item_in_cart = Shopping.get_cart_item(cart.id, item.id) != nil

        {:noreply,
          socket
          |> assign(:page_title, page_title(socket.assigns.live_action))
          |> assign(:item, item)
          |> assign(:payment_request_qr_code_url, nil)
          |> assign(:cart_id, cart.id)
          |> assign(:is_favorited, is_favorited)
          |> assign(:item_in_cart, item_in_cart)
        }

      nil ->
        cart = nil
        item_in_cart = nil

        {:noreply,
          socket
          |> assign(:page_title, page_title(socket.assigns.live_action))
          |> assign(:item, item)
          |> assign(:payment_request_qr_code_url, nil)
          |> assign(:cart_id, nil)
          |> assign(:is_favorited, is_favorited)
          |> assign(:item_in_cart, item_in_cart)
        }
    end
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
  def handle_event("add_to_cart", %{"item_id" => item_id}, socket) do
    # Shopping.add_to_cart(socket.assigns.cart_id, item_id)
    case Shopping.add_to_cart(socket.assigns.current_user.id, item_id) do
      {:ok, _cart_item} ->
        socket = assign(socket, item_in_cart: true)
        {:noreply, put_flash(socket, :info, "Added to cart!")}

      {:error, :already_in_cart} ->
        {:noreply, put_flash(socket, :error, "Item is already in your cart!")}
    end

  end

  @impl true
  def handle_event("remove_from_cart", %{"item_id" => item_id}, socket) do
    case Shopping.remove_from_cart(socket.assigns.current_user.id, item_id) do
      {:ok, _cart_item_id} ->
        socket = assign(socket, item_in_cart: false)
        {:noreply, put_flash(socket, :info, "Item removed from cart")}

      {:error, :not_in_cart} ->
        {:noreply, put_flash(socket, :error, "Item wasn't in your cart!")}
    end

  end

  @impl true
  def handle_event("buy_now", %{"value" => item_id}, socket) do
    # payment_address = "Payments.generate_payment_request()"
    payment_address = ""
    {:noreply, assign(socket, payment_request: "true",
      payment_address: payment_address)
    }
  end

  @impl true
  def handle_event("handcash_payment_request", params, socket) do
    paymentRequestParams = %{
      "product" => %{
        "name" => "Test Items",
        "description" => "A thing to buy",
        "imageUrl" => "https://afomi.com/assets/images/rw-stamp.svg"
      },
      "receivers" => [
        %{
          "sendAmount" => 0.0001,
          "destination" => "afomi"
        }
      ],
      "notifications" => %{
        "webhook" => %{
          "customParameters" => %{
            "gameId" => "123455"
          },
          "webhookUrl" => "https://localhost:4000/handcash/webhook"
        },
        "email" => "afomi@handcash.io"
      },
      "currencyCode" => "BSV",
      "denominatedIn" => "USD",
      "expirationType" => "limit",
      "totalUnits" => 1,
      "expirationInSeconds" => 60 * 60 * 2,
      "redirectUrl" =>
        "https://localhost:4000/webhooks"
    }

    updatedPaymentRequestParams = %{
      "product" => %{
        "name" => "Testing Items2",
        "description" => "A thing to buy again",
        "imageUrl" => "https://afomi.com/assets/images/rw-stamp.svg"
      },
    }

    case socket.assigns.handcash_client |> Handkit.Wallet.create_payment_request(paymentRequestParams) do
      {:ok, response} ->
        %{
          "payment_request_qr_code_url" => payment_request_qr_code_url,
          "payment_request_url" => payment_request_url
        } = response
        # payment_address = "Payments.generate_payment_request()"

        payment_address = ""
        {:noreply, assign(socket,
            payment_address: payment_address,
            payment_request_qr_code_url: payment_request_qr_code_url,
            payment_request_url: payment_request_url
          )
        }

      {:error, _} ->
        IEx.pry

      _ ->
        payment_address = ""
        {:noreply, assign(socket,
            payment_request: "true",
            payment_address: payment_address
          )
        }
    end
  end

  defp page_title(:show), do: "Show Item"
  defp page_title(:edit), do: "Edit Item"
end
