defmodule QartWeb.PageControllerTest do
  use QartWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "open source software"
    assert html_response(conn, 200) =~ "qart.app"
    assert html_response(conn, 200) =~ "peer to peer commerce"
  end
end
