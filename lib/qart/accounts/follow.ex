defmodule Qart.Accounts.Follow do
  use Ecto.Schema
  import Ecto.Changeset

  schema "follows" do
    belongs_to :user, Qart.Accounts.User
    belongs_to :followed_user, Qart.Accounts.User, foreign_key: :followed_user_id

    timestamps()
  end

  def changeset(favorite, attrs) do
    favorite
    |> cast(attrs, [:user_id, :followed_user_id])
    |> validate_required([:user_id, :followed_user_id])
    |> unique_constraint([:user_id, :followed_user_id])
  end
end
