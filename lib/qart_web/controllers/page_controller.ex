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

  def start(conn, _params) do
    render(conn, :start,
      items: Qart.Inventory.list_items(),
      page_title: "Start"
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
end
