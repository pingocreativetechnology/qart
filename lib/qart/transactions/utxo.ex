defmodule Qart.Transactions.Utxo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "utxos" do
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
    |> cast(attrs, [:txid, :vout, :satoshis, :script, :address, :spent, :spent_at])
    |> validate_required([:txid, :vout, :satoshis, :script])
  end

  @doc """
  Convert this Ecto Utxo struct into a BSV.Utxo.
  """
  def to_bsv_utxo(%__MODULE__{} = utxo) do
    {:ok, utxo } =BSV.UTXO.from_params(%{
      "txid" => utxo.txid,
      "vout" => utxo.vout,
      "satoshis" => utxo.satoshis,
      "script" => utxo.script,
    })
    utxo
  end
end
