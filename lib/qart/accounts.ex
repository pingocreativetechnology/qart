defmodule Qart.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Qart.Repo

  alias Qart.Accounts.{User, UserToken, UserNotifier}
  alias Qart.Accounts.{Favorite, Follow}
  alias Qart.Inventory.Item
  alias Qart.Wallet.Wallet
  alias Qart.Wallet.Address

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def list_users do
    Repo.all(User)
    |> Enum.map(&maybe_compute_display_name/1)
  end

  def get_favorited_items(user_id) do
    user = Repo.get(User, user_id)
    |> Repo.preload(:favorited_items)
    user.favorited_items
  end

  def get_following(user_id) do
    from(u in User,
      join: f in Follow, on: f.user_id == ^user_id and f.followed_user_id == u.id,
      left_join: f2 in Follow, on: f2.user_id == u.id and f2.followed_user_id == ^user_id,
      where: is_nil(f2.id),
      select: u
    )
    |> Repo.all()
    |> Enum.map(fn user ->
      user |> maybe_compute_display_name
    end)
  end

  def get_followers(user_id) do
    from(u in User,
      join: f in Follow, on: f.followed_user_id == ^user_id and f.user_id == u.id,
      left_join: f2 in Follow, on: f2.user_id == ^user_id and f2.followed_user_id == u.id,
      where: is_nil(f2.id),
      select: u
    )
    |> Repo.all()
    |> Enum.map(fn user ->
      user |> maybe_compute_display_name
    end)
  end

  def get_mutuals(user_id) do
    from(u in User,
      join: f1 in Follow, on: f1.user_id == ^user_id and f1.followed_user_id == u.id,
      join: f2 in Follow, on: f2.followed_user_id == ^user_id and f2.user_id == u.id,
      select: u
    )
    |> Repo.all()
    |> Enum.map(fn user ->
      user |> maybe_compute_display_name
    end)
  end

  def get_joined_favorited_items(user_id) do
    from(i in Item,
      join: f in Favorite, on: f.item_id == i.id,
      where: f.user_id == ^user_id,
      select: i
    )
    |> Repo.all()
  end


  def maybe_compute_display_name(nil), do: nil
  def maybe_compute_display_name(user) do
    %{user |
      display_name: Qart.Accounts.User.display_name(user),
      try_handle: Qart.Accounts.User.try_handle(user),
      gradient: Qart.Accounts.User.gradient(user),
      role: Qart.Accounts.User.role(user)
    }
  end

  def get_handcash_user_info(handcash_profile) do
   %{"public_profile" => %{
        "paymail" => email,
        "display_name" => display_name,
        "id" => provider_id,
        "avatar_url" => avatar_url,
      }
    } = handcash_profile

    {:ok, %{
      email: email,
      name: display_name,
      provider_uid: provider_id,
      provider: "handcash",
      avatar_url: avatar_url
      }
    }
  end

  # used for Handcash
  def find_or_create_user(%{email: email, name: name, provider: provider, provider_uid: uid}) do
    case Repo.get_by(User, email: email) do
      nil ->
        %User{}
        |> User.handcash_changeset(%{
          email: email,
          name: name,
          provider: provider,
          provider_uid: uid
        })
        |> Repo.insert()

      user ->
        {:ok, user}
    end
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_by_handle(handle) when is_binary(handle) do
    case Integer.parse(handle) do
      {id, ""} -> Repo.get!(User, id)
        |> maybe_compute_display_name

      _ -> Repo.get_by!(User, handle: handle)
        |> maybe_compute_display_name
    end
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  def change_user_handle(user) do
    User.handle_changeset(user, %{})
  end

  def update_user_handle(user, attrs) do
    user
    |> User.handle_changeset(attrs)
    |> Repo.update()
  end

  def update_user_settings(user, attrs) do
    user
    |> User.settings_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  def change_user_settings(user, attrs \\ %{}) do
    User.settings_changeset(user, attrs,
      publish_public_profile: false,
      publish_public_items: false,
      publish_public_posts: false
    )
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  def get_user_wallet(user_id, wallet_id) do
    Repo.get_by(Wallet,
      user_id: user_id,
      id: wallet_id
    )
  end

  def update_wallet_name(%Wallet{} = wallet, %{name: name} = attrs) do
    wallet
    |> Wallet.name_changeset(%{name: name})
    |> Repo.update()
  end

  def get_user_active_wallet(user_id) do
    query =
      from f in Wallet,
        where: f.user_id == ^user_id,
        order_by: [asc: f.id]

    query |> first |> Repo.one
  end

  def get_user_wallets(user_id) do
    Wallet
    |> where(user_id: ^user_id)
    |> order_by(asc: :id)
    |> Repo.all()
  end

  def has_pubkey_hash?(pubkey_hash) do
    true
    # Wallet
    # |> where(user_id: ^user_id)
    # |> order_by(asc: :id)
    # |> Repo.all()
  end

  def preload_utxos(address) do
    utxos = Qart.Transactions.list_utxos_by_address(address.address)
    %{address |
      utxos: utxos
    }
  end

  def set_default_wallet(%User{} = user, wallet_id) do
    user
    |> Ecto.Changeset.change(default_wallet_id: wallet_id)
    |> Repo.update()
  end

  def get_wallet_addresses(wallet_id) do
    query =
      from f in Address,
        where: f.wallet_id == ^wallet_id,
        order_by: [asc: f.id]

    addresses = Repo.all(query)
      |> Enum.map(&preload_utxos/1)

    addresses
  end

  def delete_wallet(%Wallet{} = wallet) do
    Repo.delete(wallet)
  end

  def get_address_by_pubkey_hash(pubkey_hash) do
    query =
      from f in Address,
        where: f.pubkey_hash == ^pubkey_hash

    address = Repo.one(query)
    address
  end

  def get_address_keypair(wallet_id, address) do
    query =
      from f in Address,
        where: f.wallet_id == ^wallet_id,
        where: f.address == ^address

    address = Repo.one(query)

    # take the wallet and address's derivation path to regenerate the keypair
    address
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
      |> maybe_compute_display_name
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &url(~p"/users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """

  def confirm_user(token) do
    case Application.get_env(:qart, :env) do
      :dev ->
        Repo.update!(User.confirm_changeset(token))

      _ ->
        with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
            %User{} = user <- Repo.one(query),
            {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
          {:ok, user}
        else
          _ -> :error
        end
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &url(~p"/users/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """

  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)  when is_function(reset_password_url_fun, 1) do
    case Mix.env do
      :dev ->
        {:ok, :skipped_email} # TODO: Temporary, until email is fixed

      _ ->
        {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
        Repo.insert!(user_token)
        UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
    end
  end


  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end
end
