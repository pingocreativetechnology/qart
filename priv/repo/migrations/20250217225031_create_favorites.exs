defmodule Qart.Repo.Migrations.CreateFavorites do
  use Ecto.Migration

  def change do
    create table(:favorites) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :item_id, references(:items, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:favorites, [:user_id, :item_id]) # Prevent duplicate favorites
  end
end
