defmodule QartWeb.UserAvatar do
  use Phoenix.Component

  @doc """
  Renders a user avatar.

  - If `@user.avatar_url` exists, it displays an image.
  - Otherwise, it generates a custom `div` with initials.

  ## Example usage:

      <.user_avatar user={@user} class="w-12 h-12" />
  """
  attr :user, :map, required: true
  attr :class, :string, default: "user-avatar size-8 md:size-14 flex-none rounded-full inline-block mr-1 md:mr-2 mb-3 align-top"

  def user_avatar(assigns) do
    ~H"""
    <%= if @user.avatar_url do %>
      <img
        src={@user.avatar_url}
        alt={@user.display_name}
        class={@class} />
    <% else %>
      <div
        class={"bg-gradient-to-br #{@user.gradient}
        text-white font-bold text-lg " <> @class}>
      </div>
    <% end %>
    """
  end

  attr :user, :map, required: true
  attr :class, :string, default: "user-avatar size-8 flex-none rounded-full inline-block"

  def small_user_avatar(assigns) do
    ~H"""
    <%= if @user.avatar_url do %>
      <img
        src={@user.avatar_url}
        alt={@user.display_name}
        class={@class} />
    <% else %>
      <div
        class={"bg-gradient-to-br #{@user.gradient}
        text-white font-bold text-lg " <> @class}>
      </div>
    <% end %>
    """
  end

  attr :user, :map, required: true
  attr :class, :string, default: "user-avatar size-24 rounded-full ring-4 ring-white sm:size-32"

  def large_user_avatar(assigns) do
    ~H"""
    <%= if @user.avatar_url do %>
      <img
          src={@user.avatar_url}
          alt={@user.display_name}
          class="size-24 rounded-full ring-4 ring-white sm:size-32"
      />
    <% else %>
      <div
        class={"bg-gradient-to-br #{@user.gradient}
        text-white font-bold text-lg " <> @class}>
      </div>
    <% end %>
    """
  end

  defp user_initials(name) do
    name
    |> String.split()
    |> Enum.map(&String.first/1)
    |> Enum.join()
    |> String.upcase()
  end
end
