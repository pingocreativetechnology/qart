defmodule Qart.Wallet.Address do
  use Ecto.Schema
  import Ecto.Changeset

  schema "addresses" do
    field :wallet_id, :integer
    field :address, :string  # Public Bitcoin address
    field :derivation_path, :string  # Track the derivation path used
    field :pubkey_hash, :string

    field :utxos, {:array, :string}, virtual: true

    timestamps()
  end

  def changeset(address, attrs) do
    address
    |> cast(attrs, [:wallet_id, :address, :derivation_path])
    |> validate_required([:wallet_id, :address, :derivation_path])
  end
end
