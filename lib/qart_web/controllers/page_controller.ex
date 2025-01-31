defmodule QartWeb.PageController do
  use QartWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def start(conn, _params) do
    render(conn, :start)
  end
end
