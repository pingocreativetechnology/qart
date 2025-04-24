defmodule QartWeb.FollowButtonComponent do
  use Phoenix.LiveComponent

  alias Qart.Accounts
  alias Qart.Follows

  @impl true
  def update(assigns, socket) do
    user_id = assigns.current_user.id
    profile_user_id = assigns[:profile_user_id]
    is_following = user_id && Follows.is_followed?(user_id, profile_user_id)

    {:ok, assign(socket, assigns |> Map.put(:is_following, is_following))}
  end

  @impl true
  def handle_event("follow", %{"value" => followed_user_id}, socket) do
    user_id = socket.assigns.current_user.id

    if socket.assigns.is_following do
      Follows.unfollow_user(user_id, followed_user_id)
      {:noreply, assign(socket, is_following: false)}
    else
      Follows.follow_user(user_id, followed_user_id)
      {:noreply, assign(socket, is_following: true)}
    end

  end

  @impl true
  def render(assigns) do
    ~H"""
      <button type="button"
        phx-click="follow"
        phx-target={@myself}
        value={@profile_user_id}
        class="inline-flex justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 items-center">
      <%= if @is_following do %>
        <div class="flex-none rounded-full p-1 bg-green-400/10 text-green-400 mr-2">
          <div class="size-1.5 rounded-full bg-current"></div>
        </div>
        <span>Following</span>
      <% else %>
          <div class="flex-none rounded-full p-1 bg-green-400/10 text-slate-600 mr-2">
            <div class="size-1.5 rounded-full bg-current"></div>
          </div>
          <span>Follow</span>
      <% end %>
      </button>
    """
  end
end
