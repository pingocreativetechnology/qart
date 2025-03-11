defmodule QartWeb.Plugs.CartSession do
  import Plug.Conn
  alias Ecto.UUID

  def init(opts), do: opts

  def call(conn, _opts) do
    cart_id = get_session(conn, :cart_id) || UUID.generate()
    conn
    |> put_session(:cart_id, cart_id)
    |> assign(:cart_id, cart_id)
  end
end
