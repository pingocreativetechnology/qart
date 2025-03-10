defmodule QartWeb.AvatarUploadLive do
  use QartWeb, :live_view
  alias Qart.Repo
  alias Qart.Accounts.User
  import UUID

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:user, socket.assigns.current_user)
     |> allow_upload(:avatar, accept: ~w(.png .jpg .jpeg), max_entries: 1)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
        unique_filename = "user-id-#{socket.assigns.current_user.id}-" <> UUID.uuid4() <> Path.extname(entry.client_name)
        dest = Path.join(["priv/static/uploads", unique_filename])
        File.cp!(path, dest)

        {:ok, "/uploads/#{unique_filename}"} # Return the stored file path
      end)

    case uploaded_files do
      [avatar_url] ->
        user = socket.assigns.current_user
        changeset = User.changeset(user, %{avatar_url: avatar_url})

        case Repo.update(changeset) do
          {:ok, updated_user} ->
            socket = socket
            |> put_flash(:info, "Updated avatar successfully")
            {:noreply, assign(socket, user: updated_user)}

          {:error, _changeset} ->
            {:noreply, put_flash(socket, :error, "Failed to upload avatar.")}
        end

      _ ->
        {:noreply, put_flash(socket, :error, "No file uploaded.")}
    end
  end

  @impl true
  def handle_event("validate", _params, socket) do
    # Validate the uploaded file and show errors if necessary
    {:noreply, socket}
  end
end
