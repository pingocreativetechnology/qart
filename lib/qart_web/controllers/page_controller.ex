defmodule QartWeb.PageController do
  use QartWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home,
      page_title: "Home",
      page_description: "Peer to peer commerce",
      layout: false
    )
  end

  def start(conn, _params) do
    render(conn, :start,
      items: Qart.Inventory.list_items(),
      page_title: "Start"
    )
  end
end
