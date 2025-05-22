defmodule Qart.Repo.Migrations.AddUtxoUserId do
  use Ecto.Migration

  def change do
    alter table("utxos") do
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
