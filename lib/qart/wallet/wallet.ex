defmodule Qart.Wallet.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wallets" do
    field :user_id, :integer
    field :seed, Qart.Encrypted.Binary  # Store encrypted seed using cloak_ecto
    field :current_derivation, :integer, default: 0  # Track last used derivation index
    field :network, :string # main or test

    field :name, :string # a user-provided name
    field :description, :string # a user-provided description
    field :notes, :string # a user-provided notes
    field :code, :string # a user-provided code, maybe a gist to augment a wallet

    has_many :addresses, Qart.Wallet.Address

    timestamps()
  end

  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:user_id, :seed, :current_derivation, :network])
    |> validate_required([:user_id, :seed, :network])
  end

  def name_changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
