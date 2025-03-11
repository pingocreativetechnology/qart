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
    profile = Handkit.Profile.get_current_profile(handcash_client)

    conn = conn
      |> put_session(:handcash_oauth_token, auth_token)
      |> configure_session(renew: true)
      |> put_flash(:info, "Successfully authenticated via Handcash")
      |> redirect(to: "/")
  end
end
