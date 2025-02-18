require IEx
defmodule QartWeb.HandleLive do
  use QartWeb, :live_view
  alias Qart.Accounts

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    changeset = Accounts.change_user_handle(user)

    {:ok, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", params, socket) do
    user = socket.assigns.current_user

    case Accounts.update_user_handle(user, params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Handle set successfully!")
        }

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("validate", %{"handle" => handle}, socket) do
      {:noreply, socket}
  end
end
