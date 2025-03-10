defmodule QartWeb.Plugs.AssignHandcashAuthUrl do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    assign(conn, :handcash_auth_url, Handkit.get_redirection_url(Application.get_env(:handkit, :api_key)))
  end
end
