defmodule QartWeb.PageControllerTest do
  use QartWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Qart.app"
    assert html_response(conn, 200) =~ "peer to peer commerce"
    assert html_response(conn, 200) =~ "Try it out"
    assert html_response(conn, 200) =~ "Your social network starts"
    assert html_response(conn, 200) =~ "Run Qart locally"
  end
end
