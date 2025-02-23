defmodule QartWeb.HandleLive.Shop do
  use QartWeb, :live_view
  alias Qart.Accounts
  alias Qart.Follows
  import Phoenix.LiveView.Helpers

  @impl true
  def mount(_params, _session, socket) do
    items = Qart.Inventory.list_items()

    {:ok, assign(socket, items: items, is_favorited: false, tip_open: false)}
  end

  @impl true
  def handle_params(%{"handle" => handle}, _url, socket) do
    case Accounts.get_user_by_handle(handle) do
      nil ->
        # raise Phoenix.Router.NoRouteError, conn: %Plug.Conn{}, message: "Item not found"
        {:noreply, socket}

      profile_user ->
        user_id = socket.assigns.current_user && socket.assigns.current_user.id
        is_followed = if user_id, do: Follows.is_followed?(user_id, profile_user.id), else: false

        {:noreply, assign(socket,
          user: profile_user,
          page_title: "#{profile_user.display_name}'s Profile",
          is_followed: is_followed)
        }
    end
  end

  @impl true
  def handle_info(:set_404_status, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.live_action, status: 404)}
  end
end
