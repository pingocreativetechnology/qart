defmodule QartWeb.AskButtonComponent do
  use Phoenix.LiveComponent

  @impl true
  def update(assigns, socket) do
    user_id = assigns.current_user.id
    profile_user_id = assigns[:profile_user_id]
    # is_following = user_id && Follows.is_followed?(user_id, profile_user_id)

    {:ok, assign(socket, open: false, user_id: user_id)}
    # {:ok, socket}
  end

  @impl true
  def handle_event("toggle_ask", %{"value" => followed_user_id}, socket) do
    # user_id = socket.assigns.current_user.id

    if socket.assigns.open do
    #   Follows.unfollow_user(user_id, followed_user_id)
      {:noreply, assign(socket, open: false)}
    else
      #   Follows.follow_user(user_id, followed_user_id)
      #   {:noreply, assign(socket, is_following: true)}
      {:noreply, assign(socket, open: true)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <button
        phx-click="toggle_ask"
        phx-target={@myself}
        value={@user_id}
        class="inline-flex justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50">
        <svg class="-ml-0.5 mr-1.5 size-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none"
          viewBox="0 0 24 24" aria-hidden="true" stroke="currentColor" data-slot="icon">
          <path stroke-linecap="round" stroke-linejoin="round"
            d="M20.25 8.511c.884.284 1.5 1.128 1.5 2.097v4.286c0 1.136-.847 2.1-1.98 2.193-.34.027-.68.052-1.02.072v3.091l-3-3c-1.354 0-2.694-.055-4.02-.163a2.115 2.115 0 0 1-.825-.242m9.345-8.334a2.126 2.126 0 0 0-.476-.095 48.64 48.64 0 0 0-8.048 0c-1.131.094-1.976 1.057-1.976 2.192v4.286c0 .837.46 1.58 1.155 1.951m9.345-8.334V6.637c0-1.621-1.152-3.026-2.76-3.235A48.455 48.455 0 0 0 11.25 3c-2.115 0-4.198.137-6.24.402-1.608.209-2.76 1.614-2.76 3.235v6.226c0 1.621 1.152 3.026 2.76 3.235.577.075 1.157.14 1.74.194V21l4.155-4.155" />
        </svg>
        <span>Ask</span>
      </button>

      <div :if={@open} class="mt-2">
        <textarea phx-blur="submit_ask" phx-target={@myself}
          class="w-full p-2 border rounded-md"
          placeholder="What do you need help with?"></textarea>
      </div>
    </div>
    """
  end
end
