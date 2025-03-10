defmodule Qart.Repo.Migrations.AddItemUser do
  use Ecto.Migration

  def change do
    alter table("items") do
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
