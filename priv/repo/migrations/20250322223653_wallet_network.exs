defmodule Qart.Repo.Migrations.WalletNetwork do
  use Ecto.Migration

  def change do
     alter table(:wallets) do
      add :network, :string
    end
  end
end
