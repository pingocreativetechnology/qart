defmodule Qart.Repo.Migrations.AddAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :wallet_id, references(:wallets, on_delete: :delete_all)
      add :address, :string, null: false
      add :derivation_path, :string, null: false

      timestamps()
    end
  end
end
