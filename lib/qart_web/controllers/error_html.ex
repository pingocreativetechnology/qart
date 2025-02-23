defmodule QartWeb.ErrorHTML do
  use QartWeb, :html

  # If you want to customize your error pages,
  # uncomment the embed_templates/1 call below
  # and add pages to the error directory:
  #
  #   * lib/qart_web/controllers/error_html/404.html.heex
  #   * lib/qart_web/controllers/error_html/500.html.heex
  #
  embed_templates "error_html/*"

  # The default is to render a plain text page based on
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def render("404.html", assigns) do
    assigns = Map.put(assigns, :page_title, "Page Not Found")
    QartWeb.LayoutView.render("root.html", assigns) |> Phoenix.HTML.Safe.to_iodata()
  end

  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
