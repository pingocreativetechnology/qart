defmodule Qart.Repo.Migrations.AddUserDefaultWalletId do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :default_wallet_id, references(:wallets,
        on_delete: :nilify_all
      )
    end

    create index(:users, [:default_wallet_id])
  end
end
