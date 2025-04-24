defmodule QartWeb.TipButtonComponent do
  use Phoenix.LiveComponent

  alias Qart.Accounts
  alias Qart.Follows

  @impl true
  def update(assigns, socket) do
    # user_id = assigns.current_user.id
    # profile_user_id = assigns[:profile_user_id]
    # is_following = user_id && Follows.is_followed?(user_id, profile_user_id)
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def handle_event("tip-open", %{"value" => target_user_id}, socket) do
    user_id = socket.assigns.current_user.id

    if socket.assigns.open do
      send_update(QartWeb.TipComponent, id: "tip", open: false)
      socket = assign(socket, open: false)
      {:noreply, socket}
    else
      socket = assign(socket, open: true)
      send_update(QartWeb.TipComponent, id: "tip", open: true)
      {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <button
      type="button"
      phx-click="tip-open"
      phx-target={@myself}
      value={@target_user.id}
      class={"inline-flex justify-center rounded-md px-3 py-2 text-sm font-semibold  shadow-sm ring-1 ring-inset text-gray-900 " <>
        if @open,
          do: "bg-gray-100 hover:bg-gray-50 ring-gray-400",
          else: "bg-white  hover:bg-gray-50 ring-gray-300"}>
      <svg class="-ml-0.5 mr-1.5 size-5 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none"
        viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round"
          d="M15.042 21.672 13.684 16.6m0 0-2.51 2.225.569-9.47 5.227 7.917-3.286-.672ZM12 2.25V4.5m5.834.166-1.591 1.591M20.25 10.5H18M7.757 14.743l-1.59 1.59M6 10.5H3.75m4.007-4.243-1.59-1.59" />
      </svg>
      <span>Tip</span>
    </button>
    """
  end
end
