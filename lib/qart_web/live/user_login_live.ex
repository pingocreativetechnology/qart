defmodule QartWeb.UserLoginLive do
  use QartWeb, :live_view

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    handcash_auth_url = Handkit.get_redirection_url(Application.get_env(:handkit, :api_key))
    {:ok,
      assign(socket,
        form: form,
        handcash_auth_url: handcash_auth_url),
        temporary_assigns: [
          form: form,
          # html_class: "h-full bg-white",
          # body_class: "h-full",
        ]
    }
  end
end
