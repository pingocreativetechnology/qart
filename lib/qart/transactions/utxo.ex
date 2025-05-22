defmodule Qart.Transactions.Utxo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "utxos" do
    belongs_to :user, Qart.Accounts.User

    field :script, :string
    field :txid, :string
    field :vout, :integer
    field :satoshis, :integer
    field :spent, :boolean, default: false
    field :spent_at, :utc_datetime
    field :address, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(utxo, attrs) do
    utxo
    |> cast(attrs, [:txid, :vout, :satoshis, :script, :address, :spent, :spent_at, :user_id])
    |> validate_required([:txid, :vout, :satoshis, :spent])
  end

  @doc """
  Convert this Ecto Utxo struct into a BSV.Utxo.
  """
  def to_bsv_utxo(%__MODULE__{} = u) do
    case u.script do
      "" ->
        false

      nil ->
        false

      _ -> {:ok, utxo} = BSV.UTXO.from_params(%{
          "txid" => u.txid,
          "vout" => u.vout,
          "satoshis" => u.satoshis,
          "script" => u.script,
        })
        utxo
    end
  end
end
