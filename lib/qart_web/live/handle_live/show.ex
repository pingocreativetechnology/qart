defmodule QartWeb.HandleLive.Show do
  use QartWeb, :live_view
  alias Qart.Accounts
  alias Qart.Follows
  import Phoenix.LiveView.Helpers

  @impl true
  def mount(_params, _session, socket) do
    items = Qart.Inventory.list_items()

    user_id = if socket.assigns.current_user, do: socket.assigns.current_user.id, else: nil

    favorited_items = if user_id, do: Accounts.get_favorited_items(user_id), else: []
    following = []
    followers = []

    {:ok, assign(socket, %{
        items: items,
        is_favorited: false,
        favorited_items: favorited_items,
        following: following,
        followers: followers
      })
    }
  end

  @impl true
  def handle_params(%{"handle" => handle}, _url, socket) do
    case Accounts.get_user_by_handle(handle) do
      nil ->
        # raise Phoenix.Router.NoRouteError, conn: %Plug.Conn{}, message: "Item not found"
        {:noreply, socket}

      profile_user ->
        user_id = if @current_user, do: socket.assigns.current_user.id, else: nil
        is_followed = if @current_user, do: Follows.is_followed?(user_id, profile_user.id), else: false
        following = Accounts.get_following(profile_user.id)
        followers = Accounts.get_followers(profile_user.id)
        Qart.debug(followers)

        {:noreply, assign(socket,
            user: profile_user,
            page_title: "#{profile_user.display_name}'s Profile",
            is_followed: is_followed,
            following: following,
            followers: followers
        )}
    end
  end

  @impl true
  def handle_info(:set_404_status, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.live_action, status: 404)}
  end

end
