defmodule QartWeb.HandleLive.Invite do
  use QartWeb, :live_view
  alias Qart.Mailer
  alias Qart.Forms.ContactForm
  import Phoenix.LiveView.Helpers

  # for email stuff
  import Swoosh.Email
  alias Qart.Mailer

  @impl true
  def mount(_params, _session, socket) do
    email_changeset = ContactForm.changeset(%{})
    {:ok, assign(socket, form: to_form(email_changeset), sent: false)}
  end

  @impl true
  def handle_params(%{}, _url, socket) do
    email_changeset = ContactForm.changeset(%{})

    {:noreply, assign(socket, form: to_form(email_changeset))}
  end

  def handle_event(send_email, %{
      "email" => user_email,
      "message" => message
    }, socket) do

    message = if String.trim(message) === "" do
      "empty"
    else
      message
    end

    email =
      new()
      |> to(user_email)
      |> from({"Qart", "contact@example.com"})
      |> subject("You have been invited to Qart")
      |> text_body(message)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end

    socket = socket
      |> put_flash(:info, "Invite sent successfully")

    socket = assign(socket, sent: true)
    {:noreply, socket }
  end
end
