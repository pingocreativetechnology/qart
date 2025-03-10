defmodule Qart.Repo.Migrations.CreateCartItems do
  use Ecto.Migration

  def change do
    create table(:cart_items) do
      add :quantity, :integer
      add :cart_id, references(:carts, on_delete: :nothing)
      add :item_id, references(:items, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:cart_items, [:cart_id])
    create index(:cart_items, [:item_id])
  end
end
