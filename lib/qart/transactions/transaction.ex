defmodule Qart.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :raw, :string
    field :version, :string
    field :inputs, :string
    field :txid, :string
    field :block_hash, :string
    field :outputs, {:array, :string}, default: []
    field :merkle_proof, :string

    field :spent, :boolean, default: false
    field :notes, :string
    field :addresses, {:array, :string}, default: []

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:txid, :raw, :version, :block_hash, :inputs, :outputs, :merkle_proof, :spent, :addresses, :notes])
    |> validate_required([:txid, :raw])
  end
end
