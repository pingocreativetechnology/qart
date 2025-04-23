defmodule Qart.Repo.Migrations.AddAddressPubkeyHash do
  use Ecto.Migration

  def change do
    alter table("addresses") do
      add :pubkey_hash, :string
    end
  end
end
