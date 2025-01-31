defmodule Qart.Inventory.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :name, :string
    field :status, :string
    field :description, :string
    field :price, :decimal
    field :tags, {:array, :string}, default: []

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :description, :price, :tags, :status])
    |> validate_required([:name, :description])
  end
end
