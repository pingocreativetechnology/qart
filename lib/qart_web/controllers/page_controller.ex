defmodule QartWeb.PageController do
  use QartWeb, :controller
  alias Qart.Accounts

  def home(conn, _params) do
    render(conn, :home,
      layout: false,
      page_title: "Home",
      page_description: "Peer to peer commerce",
      users: Qart.Accounts.list_users
    )
  end

  def about(conn, _params) do
    render(conn, :about,
      page_title: "About"
    )
  end

  def catalog(conn, _params) do
    render(conn, :catalog,
      items: Qart.Inventory.list_items(),
      page_title: "Catalog"
    )
  end

  def profile(conn, %{"handle" => handle}) do
    case Accounts.get_user_by_handle(handle) do
      nil ->
        conn
        |> put_flash(:error, "User not found")
        |> put_status(:not_found) # Set HTTP status to 404
        |> put_view(QartWeb.ErrorHTML) # Use the custom error view
        |> render("404.html") # Render the 404 template
        |> halt() # Stop further processing

      user ->
        render(conn, :profile,
          user: user,
          page_title: "#{user.handle} on Qart"
        )
    end
  end

  def map(conn, _params) do
    render(conn, :map)
  end

  def handcash_auth(conn, %{"authToken" => auth_token}) do
    handcash_client = Handkit.create_connect_client(auth_token)
    {:ok, handcash_profile} = Handkit.Profile.get_current_profile(handcash_client)

    case Qart.Accounts.get_handcash_user_info(handcash_profile) do
      {:ok, user_info} ->
        case Accounts.find_or_create_user(user_info) do
          {:ok, user} ->
            conn
            |> QartWeb.UserAuth.log_in_user(user)
            |> put_flash(:info, "Successfully authenticated via Handcash")
            |> redirect(to: "/")

          {:error, changeset} ->
            conn
            |> put_flash(:error, "Could not create user")
            |> redirect(to: "/users/log_in")
        end

      {:error, reason} ->
        conn
        |> put_flash(:error, "OAuth failed: #{reason}")
        |> redirect(to: "/users/log_in")
    end
  end

end
