defmodule QartWeb.UserSettingsLive do
  use QartWeb, :live_view

  alias Qart.Repo
  alias Qart.Accounts
  alias Qart.Accounts.{User}

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)
    settings_changeset = Accounts.change_user_settings(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:settings_form, to_form(settings_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  def handle_event("update_settings", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_settings(user, user_params) do
      {:ok, user} ->
        settings_form =
          user
          |> Accounts.change_user_settings(user_params)
          |> to_form()

        socket = socket |> put_flash(:info, "Updated public profile settings")
        {:noreply, assign(socket, settings_form: settings_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, settings_form: to_form(changeset))}
    end
  end


  def handle_event("download_follows_json", _params, socket) do

    items = Accounts.list_users
      |> Enum.sort_by(& &1.email)

  # Convert items to JSON using Jason
  #  json =
  #   items
  #   |> Enum.map(&Map.from_struct/1)  # Convert struct to map
  #   |> Enum.map(&Map.drop(&1, [:__meta__]))  # Remove Ecto metadata
  #   |> Jason.encode!()
  #   |> Jason.Formatter.pretty_print

  json =
    items
    |> Enum.map(fn user ->
      %{
        id: user.id,
        display_name: user.display_name,
        email: user.email,
        handle: user.handle,
      }
    end)
    # |> Enum.sort_by(& &1.email)
    # |> Enum.sort_by(fn {key, _value} -> to_string(key) end)  # Sort keys
    # |> Enum.into(%{})  # Convert back to a map
    |> Jason.encode!()
    |> Jason.Formatter.pretty_print

    {:noreply,
      push_event(socket, "download_following_json", %{filename: "follows.json", content: json})}
  end

  def handle_event("download_followers_json", _params, socket) do
    user_id = socket.assigns.current_user.id
    user = Repo.get(User, user_id)
      |> Repo.preload(:followers)

    json =
      user.followers
      |> Enum.map(fn user ->
        %{
          id: user.id,
          display_name: user.display_name,
          email: user.email,
          handle: user.handle,
        }
      end)

      |> Jason.encode!()
      |> Jason.Formatter.pretty_print

    {:noreply,
      push_event(socket, "download_followers_json", %{filename: "followers.json", content: json})}
  end
end
