defmodule Qart.Transactions do
  @moduledoc """
  The Transactions context.
  """
  require IEx

  import Ecto.Query, warn: false
  alias Qart.Repo

  alias Qart.Transactions.Transaction

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions do
    Repo.all(Transaction)
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end


  # JungleBus functions ########################################################
  def parse_transaction do
    txid = "6e93e17cf98c1af0f851454e984942d72704412369e8b85ca74262285857b2d4"
    transaction = "AQAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP////8XA52NDS9DVVZWRS9LyH9b7vhTJywAAAD/////Ac5toBIAAAAAGXapFNZIaGz2A8EYUPOWAONzEnOKzMqPiKwAAAAA"
    z = BSV.Tx.from_binary(transaction, encoding: :base64)
    Qart.debug(z)
    z
  end

  def call_junglebus(txid) do
    url = "https://junglebus.gorillapool.io/v1/transaction/get/#{txid}"

    response = Tesla.get!(url)
    json = response.body |> Jason.decode!

    Qart.debug(json)

    # Write the JungleBus response to the Transactions table
    new_tx = %{
      txid: json["id"],
      raw: json["transaction"],
      # outputs: json["outputs"],
      addresses: json["addresses"],
    }

    {:ok, tx} = Qart.Transactions.create_transaction(new_tx)
    # {:ok, nil}
  end

  def get_address(address) do
    bsv_network = Application.get_env(:bsv, :network)
    # url = "https://api.whatsonchain.com/v1/bsv/#{bsv_network}/address/#{address}/info"
    url = "https://api.whatsonchain.com/v1/bsv/#{bsv_network}/address/#{address}/unspent/all"

    # response =

    # Qart.debug response

    case Tesla.get(url) do
      {:error, %Mint.TransportError{reason: :nxdomain}} ->
        Qart.debug("111")
        Qart.debug(url)
        IO.puts "ya"
        {:error, nil}

      response ->
        json = response.body |> Jason.decode!
        Qart.debug(json)
        {:ok, nil}

      _ ->
        Qart.debug("333")
        IO.puts "else"
        {:ok, nil}
    end


    # %{
    #   "address" => "mo3FBnaVPmaUvBPDqLEqE2P9JyiXi56sST",
    #   "error" => "",
    #   "result" => [
    #     %{
    #       "hex" => "76a914528375c40efd773bbc21b8146536b73c229a0a0688ac",
    #       "isSpentInMempoolTx" => false,
    #       "status" => "unconfirmed",
    #       "tx_hash" => "3a34b6c5e49cfa9841631cf6aa7120d044c0916f1a7f2d1bb0d95841df54b700",
    #       "tx_pos" => 0,
    #       "value" => 99904
    #     },
    #     %{
    #       "height" => 1666107,
    #       "isSpentInMempoolTx" => false,
    #       "status" => "confirmed",
    #       "tx_hash" => "3a34b6c5e49cfa9841631cf6aa7120d044c0916f1a7f2d1bb0d95841df54b700",
    #       "tx_pos" => 0,
    #       "value" => 99904
    #     }
    #   ],
    #   "script" => "8b447290eea5989eaaeb98dedfc8ee95f3600a122f98f07ffe856b214ab68aac"
    # }

    # # Write the JungleBus response to the Transactions table
    # new_tx = %{
    #   txid: json["id"],
    #   raw: json["transaction"],
    #   # outputs: json["outputs"],
    #   addresses: json["addresses"],
    # }

    # {:ok, tx} = Qart.Transactions.create_transaction(new_tx)

  end

  def get_tx(txid) do
    bsv_network = Application.get_env(:bsv, :network)
    # url = "https://api.whatsonchain.com/v1/bsv/#{bsv_network}/tx/hash/#{txid}"
    # url = "https://api.whatsonchain.com/v1/bsv/main/tx/hash/6e93e17cf98c1af0f851454e984942d72704412369e8b85ca74262285857b2d4"
    url = "https://api.whatsonchain.com/v1/bsv/#{bsv_network}/tx/#{txid}/hex"

    case Tesla.get(url) do
      {:error, %Mint.TransportError{reason: :nxdomain}} ->
        {:error, nil}

      response ->
        Qart.debug(response.body)
        # json = response.body |> Jason.decode!

        # Qart.debug(json)
        z = response.body |> hex_to_base64()
        Qart.debug z

        # What's on Chain response
        new_tx = %{
          txid: txid,
          # raw: response.body,
          raw: z,
          # outputs: json["outputs"],
          # addresses: json["addresses"],
        }

        {:ok, tx} = Qart.Transactions.create_transaction(new_tx)
    end

    # # Write the JungleBus response to the Transactions table
    # new_tx = %{
    #   txid: json["id"],
    #   raw: json["transaction"],
    #   # outputs: json["outputs"],
    #   addresses: json["addresses"],
    # }
  end

  def hex_to_base64(hex) do
    with {:ok, binary} <- Base.decode16(hex, case: :mixed) do
      Base.encode64(binary)
    else
      _ -> {:error, "Invalid hex string"}
    end
  end
end
