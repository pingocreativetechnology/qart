defmodule Qart.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import QartWeb.Helpers, only: [get_gradient: 1]

  schema "users" do
    field :email, :string
    field :handle, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :current_password, :string, virtual: true, redact: true
    field :confirmed_at, :utc_datetime

    field :display_name, :string, virtual: true
    field :try_handle, :string, virtual: true
    field :gradient, :string, virtual: true
    field :role, :string, virtual: true
    field :avatar_url, :string

    field :provider, :string  # :handcash
    field :provider_uid, :string # handcash :id

    has_many :favorites, Qart.Accounts.Favorite
    has_many :favorited_items, through: [:favorites, :item]

    # Users this user follows
    has_many :outgoing_follows, Qart.Accounts.Follow, foreign_key: :user_id
    has_many :following, through: [:outgoing_follows, :followed_user]

    # Users who follow this user
    has_many :incoming_follows, Qart.Accounts.Follow, foreign_key: :followed_user_id
    has_many :followers, through: [:incoming_follows, :user]

    timestamps(type: :utc_datetime)
  end

  # Compute the display_name dynamically
  def display_name(%__MODULE__{handle: nil, email: email}), do: email
  def display_name(%__MODULE__{handle: handle}), do: handle

  def try_handle(%__MODULE__{handle: nil, id: id}), do: id
  def try_handle(%__MODULE__{handle: handle}), do: handle

  def gradient(%__MODULE__{email: email}), do: get_gradient(email)
  def role(%__MODULE__{email: email}), do: "Role"

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:avatar_url])
  end

  def handcash_changeset(user, attrs, opts \\ []) do
    throwaway_password = :crypto.strong_rand_bytes(32) |> Base.encode64()

    user
    |> cast(attrs, [:email, :password, :provider, :provider_uid])
    |> validate_required([:email, :provider, :provider_uid])
    |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(throwaway_password))
  end

  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_email(opts)
    |> validate_password(opts)
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    # Examples of additional password validation:
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, Qart.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  def handle_changeset(user, attrs) do
    forbidden_handles = ~w(start item items user users handle home fuck)

    user
    |> cast(attrs, [:handle])
    |> validate_required([:handle])
    |> update_change(:handle, &String.downcase/1) # force lowercase
    |> validate_length(:handle, min: 3, max: 20)
    |> validate_format(:handle, ~r/^[a-z0-9_-]+$/, message: "Only lowercase letters, numbers, - and _ allowed")
    |> validate_exclusion(:handle, forbidden_handles, message: "This handle is reserved")
    |> unique_constraint(:handle)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%Qart.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    changeset = cast(changeset, %{current_password: password}, [:current_password])

    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end
