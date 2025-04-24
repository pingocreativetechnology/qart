defmodule QartWeb.HandleLive.Show do
  use QartWeb, :live_view
  alias Qart.Accounts
  alias Qart.Follows
  import Phoenix.LiveView.Helpers
  alias Qart.Posts

  import QartWeb.Post

  @impl true
  def mount(_params, _session, socket) do
    items = Qart.Inventory.list_items()

    user_id = if socket.assigns.current_user, do: socket.assigns.current_user.id, else: nil

    favorited_items = if user_id, do: Accounts.get_favorited_items(user_id), else: []
    following = []
    followers = []
    mutuals = []

    {:ok, assign(socket, %{
        items: items,
        is_favorited: false,
        favorited_items: favorited_items,
        following: following,
        followers: followers,
        mutuals: mutuals,
      })
    }
  end

  # @impl true
  # def handle_event("follow", %{"value" => followed_user_id}, socket) do
  # def handle_event("ShakeEm", _params, socket) do
  #   Qart.debug("weeeeee")
  #   # {:noreply, socket}
  #   {:noreply,
  #     push_event(socket, "shake_em", %{})}
  # end

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
        mutuals = Accounts.get_mutuals(profile_user.id)
        posts = Posts.list_user_posts(profile_user.id)
        favorited_items = Accounts.get_favorited_items(profile_user.id)

        {:noreply, assign(socket,
            user: profile_user,
            page_title: "#{profile_user.display_name}'s Profile",
            is_followed: is_followed,
            following: following,
            followers: followers,
            mutuals: mutuals,
            favorited_items: favorited_items,
            posts: posts
        )}
    end
  end

  @impl true
  def handle_info(:set_404_status, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.live_action, status: 404)}
  end

  @impl true
  def handle_event("submit_post", _params, socket) do
    IO.puts("Post submitted!")
    handle = socket.assigns.current_user.try_handle
    # {:noreply, put_flash(socket, :info, "Post submitted successfully!")}
    # {:noreply, push_patch(socket, to: ~p"/#{handle}/posts/new")}
    {:noreply, push_navigate(socket, to: ~p"/#{handle}/posts/new")}
  end

  # def handle_event("create_post", %{"content" => content, "attachments" => attachments, "payment_amount" => payment} = params, socket) do
  def handle_event("create_post", %{"content" => content, "payment_amount" => payment}, socket) do
      user_id = socket.assigns.current_user.id

      # Convert attachments to a list of file paths or URLs
      # attachment_urls = Enum.map(attachments, fn a -> a["filename"] end)

      attrs = %{
        user_id: user_id,
        content: content,
        payment_amount: Decimal.new(payment)
      }

      case Posts.create_post(attrs) do
        {:ok, _post} ->
          {:noreply, put_flash(socket, :info, "Post created successfully")}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Failed to create post")}
      end
    end
  # end


end
