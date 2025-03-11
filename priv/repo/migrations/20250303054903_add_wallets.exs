defmodule Qart.Repo.Migrations.AddWallets do
  use Ecto.Migration

  def change do
    create table(:wallets) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :seed, :binary  # Store encrypted seed
      add :current_derivation, :integer, default: 0

      timestamps()
    end
  end
end
