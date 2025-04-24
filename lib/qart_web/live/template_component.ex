defmodule QartWeb.TemplateComponent do
  use Phoenix.LiveComponent

  # alias Qart.Accounts
  alias Qart.Follows

  # @impl true
  # def update(assigns, socket) do
  #   # user_id = assigns.current_user.id
  #   # profile_user_id = assigns[:profile_user_id]
  #   # is_following = user_id && Follows.is_followed?(user_id, profile_user_id)

  #   # {:ok, assign(socket, assigns |> Map.put(:is_following, is_following))}
  #   {:ok, socket}
  # end

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
      <div>
      HIII
      </div>
    """
  end
end
