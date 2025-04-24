defmodule Qart.WhatsOnChain do

  import Ecto.Query, warn: false
  alias Qart.Repo

  alias Qart.Transactions.Transaction




  # JungleBus functions ########################################################
  def parse_transaction do
    txid = "6e93e17cf98c1af0f851454e984942d72704412369e8b85ca74262285857b2d4"
    transaction = "AQAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP////8XA52NDS9DVVZWRS9LyH9b7vhTJywAAAD/////Ac5toBIAAAAAGXapFNZIaGz2A8EYUPOWAONzEnOKzMqPiKwAAAAA"
    z = BSV.Tx.from_binary(transaction, encoding: :base64)
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
    url = "https://api.whatsonchain.com/v1/bsv/#{bsv_network}/address/#{address}/info"

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
  end

  def get_address_utxos(address) do
    bsv_network = Application.get_env(:bsv, :network)
    url = "https://api.whatsonchain.com/v1/bsv/#{bsv_network}/address/#{address}/unspent/all"

    case Tesla.get(url) do
      {:error, %Mint.TransportError{reason: :nxdomain}} ->
        {:error, nil}

      {:ok, response} ->
        response_body = response.body |> Jason.decode!
        {:ok, response_body}

      _ ->
        Qart.debug("333")
        IO.puts "else"
        {:ok, nil}
    end

  end

  def get_tx(txid) do
    bsv_network = Application.get_env(:bsv, :network)
    url = "https://api.whatsonchain.com/v1/bsv/#{bsv_network}/tx/#{txid}/hex"

    case Tesla.get(url) do
      {:error, %Mint.TransportError{reason: :nxdomain}} ->
        {:error, nil}

      # What's on Chain response
      {:ok, response} ->
        # Convert hex to base64
        base64 = response.body |> hex_to_base64()

        new_tx = %{
          txid: txid,
          # raw: response.body,
          raw: base64,
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

  def get_or_fetch_transaction(txid) when is_binary(txid) do
    case Repo.get_by(Transaction, txid: txid) do
      %Transaction{} = tx ->
        {:ok, tx}

      nil ->
        fetch_and_insert(txid) # also returns {:ok, tx}
    end
  end

  defp fetch_and_insert(txid) do
    {:ok, tx} = get_tx(txid)
    Qart.debug(tx)
    {:ok, tx}
  end
end
