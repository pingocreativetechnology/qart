defmodule Qart.Shopping.CartItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cart_items" do
    belongs_to :cart, Qart.Shopping.Cart
    belongs_to :item, Qart.Inventory.Item
    field :quantity, :integer, default: 1

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cart_item, attrs) do
    cart_item
    |> cast(attrs, [:cart_id, :item_id, :quantity])
    |> validate_required([:cart_id, :item_id, :quantity])
    |> validate_number(:quantity, greater_than: 0)
  end
end
