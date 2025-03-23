defmodule Qart.Wallet.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wallets" do
    field :user_id, :integer
    field :seed, Qart.Encrypted.Binary  # Store encrypted seed using cloak_ecto
    field :current_derivation, :integer, default: 0  # Track last used derivation index
    field :network, :string # main or test
    has_many :addresses, Qart.Wallet.Address

    timestamps()
  end

  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:user_id, :seed, :current_derivation, :network])
    |> validate_required([:user_id, :seed, :network])
  end
end
