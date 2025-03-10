defmodule Qart.Shopping.Cart do
  use Ecto.Schema
  import Ecto.Changeset

  schema "carts" do
    belongs_to :user, Qart.Accounts.User
    has_many :cart_items, Qart.Shopping.CartItem, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cart, attrs) do
    cart
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
  end
end
