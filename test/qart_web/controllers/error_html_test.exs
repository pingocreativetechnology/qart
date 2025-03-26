defmodule QartWeb.ErrorHTMLTest do
  use QartWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template

  test "renders 404.html" do
    assert render_to_string(QartWeb.ErrorHTML, "404", "html", []) =~ "This page does not exist"
  end

  test "renders 500.html" do
    assert render_to_string(QartWeb.ErrorHTML, "500", "html", []) == "Internal Server Error"
  end
end
