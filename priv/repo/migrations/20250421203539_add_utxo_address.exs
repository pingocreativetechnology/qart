defmodule Qart.Repo.Migrations.AddUtxoAddress do
  use Ecto.Migration

  def change do
    alter table(:utxos) do
      add :address, :string
    end
  end
end
