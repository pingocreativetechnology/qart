defmodule Qart.Repo.Migrations.AddWalletKind do
  use Ecto.Migration

  def change do
    alter table(:wallets) do
      add :kind, :string
    end
  end
end
