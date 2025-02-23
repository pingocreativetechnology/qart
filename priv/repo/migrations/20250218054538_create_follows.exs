defmodule Qart.Repo.Migrations.CreateFollows do
  use Ecto.Migration

  def change do
    create table(:follows) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :followed_user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:follows, [:user_id, :followed_user_id])
  end
end
