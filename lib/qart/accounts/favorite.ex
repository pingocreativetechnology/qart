defmodule Qart.Accounts.Favorite do
  use Ecto.Schema
  import Ecto.Changeset

  schema "favorites" do
    field :user_id, :id
    field :item_id, :id

    timestamps()
  end

  def changeset(favorite, attrs) do
    favorite
    |> cast(attrs, [:user_id, :item_id])
    |> validate_required([:user_id, :item_id])
    |> unique_constraint([:user_id, :item_id])
  end
end
