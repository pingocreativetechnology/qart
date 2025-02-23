defmodule QartWeb.UserLive.Follow do
  use QartWeb, :live_view
  alias Qart.Accounts
  alias Qart.Follows

  @impl true
  def mount(:not_mounted_at_router, %{"profile_user_id" => profile_user_id, "current_user_id" => current_user_id}, socket) do
    # user_id = socket.assigns.current_user_id
    user_id = current_user_id
    is_following = user_id && Follows.is_followed?(user_id, profile_user_id)

    {:ok, assign(socket,
      profile_user_id: profile_user_id,
      user_id: user_id,
      is_following: is_following
    )}
  end

  # def mount(%{"profile_user_id" => profile_user_id}, _session, socket) do
  #   user_id = socket.assigns.current_user_id
  #   is_following = user_id && Follows.is_followed?(user_id, profile_user_id)

  #   {:ok, assign(socket,
  #     profile_user_id: profile_user_id,
  #     user_id: user_id,
  #     is_following: is_following
  #   )}
  # end

  @impl true
  def handle_event("follow", _params, socket) do
    if socket.assigns.current_user_id do
      Follows.toggle_follow(socket.assigns.current_user_id, socket.assigns.profile_user_id)
      {:noreply, assign(socket, is_following: !socket.assigns.is_following)}
    else
      {:noreply, put_flash(socket, :error, "You must be logged in to follow users.")}
    end
  end
end
