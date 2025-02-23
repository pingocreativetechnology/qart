defmodule QartWeb.ErrorController do
  use QartWeb, :controller

  def not_found(conn, _params) do
    conn
    |> put_status(:not_found)
    |> put_view(QartWeb.ErrorHTML)
    |> put_layout({QartWeb.LayoutView, "app.html"})
    |> render("404.html")
  end
end
