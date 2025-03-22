defmodule Qart.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :txid, :string
      add :raw, :text
      add :version, :string
      add :block_hash, :string
      add :inputs, {:array, :string}
      add :outputs, {:array, :string}
      add :merkle_proof, {:array, :string}
      add :spent, :boolean, default: false, null: false, comment: "Is this Tx spent or not?"
      add :addresses, {:array, :string}, comment: "Addresses that are referenced"
      add :notes, :string

      timestamps(type: :utc_datetime)
    end

    create index("transactions", [:txid])
    create index("transactions", [:block_hash])
    create index("transactions", [:inserted_at])
  end
end
