defmodule Qart.Repo.Migrations.CreateUtxos do
  use Ecto.Migration

  def change do
    create table(:utxos) do
      add :txid, :string
      # add :item_id, references(:items, on_delete: :delete_all)
      # add :txid, references(:transactions, on_delete: :delete_all)

      add :vout, :integer
      add :satoshis, :integer
      add :script, :text
      add :spent, :boolean, default: false, null: false
      add :spent_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
