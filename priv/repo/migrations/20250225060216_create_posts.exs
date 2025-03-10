defmodule Qart.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :content, :text, null: false
      add :attachments, {:array, :string}, default: []
      add :payment_amount, :decimal, default: 0.0
      add :txid, :string
      timestamps()
    end
  end
end
