defmodule Qart.WhatsOnChain do

  import Ecto.Query, warn: false
  alias Qart.Repo
  use Tesla


  alias Qart.Transactions.Transaction

  #hex = "01000000010b2cf684964098bf5b87702e3970680d45de2da55e1e25fcf6cb1ad36b7471b2000000006b483045022100a22fddc1a734afa3177c059015c10bcf876c450cf4aeb2ebea332f11294399b302204e6fd5915549630679230d715a5b34c291591ada7f5bf65b41fa0c91dca9811c412103b654b792120e3faa3f269d2d84f40f61691023773561b8a31793511d0bc7c7e8ffffffff03305f0100000000001976a914b3182303bb218b771cc7cbf84d9ddacfbd6180b088acac260000000000001976a914627e6cb63c8759336b39784d75b3f328c65f5b6088ac00000000000000000e006a0568656c6c6f05776f726c6400000000"

  def broadcast_raw_transaction_hex(hex) do
    url = "https://api.whatsonchain.com/v1/bsv/test/tx/raw"
    post_body = %{txhex: hex} |> JSON.encode!
    Qart.debug(post_body)

    headers = [
      {"Content-Type", "application/json"}
    ]

    z = Tesla.post(url, post_body, headers)

    # case Tesla.post(url, %{txhex: hex}) do
    #   {:ok, %Tesla.Env{status: 201, body: body}} ->
    #     IO.inspect(body, label: "Created")

    #   {:ok, %Tesla.Env{status: status, body: body}} ->
    #     IO.inspect({:error, status, body})

    #   {:error, reason} ->
    #     IO.inspect(reason, label: "HTTP error")
    # end
  end

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
      addresses: json["addresses"],
    }

    {:ok, tx} = Qart.Transactions.create_transaction(new_tx)
  end

  def get_address(address) do
    bsv_network = Application.get_env(:bsv, :network)
    url = "https://api.whatsonchain.com/v1/bsv/#{bsv_network}/address/#{address}/info"

    case Tesla.get(url) do
      {:error, %Mint.TransportError{reason: :nxdomain}} ->
        {:error, nil}

      response ->
        json = response.body |> Jason.decode!
        {:ok, nil}

      _ ->
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
        {:ok, nil}
    end

  end

  def get_tx(txid) do
    bsv_network = Application.get_env(:bsv, :network)
    url = "https://api.whatsonchain.com/v1/bsv/#{bsv_network}/tx/hash/#{txid}"

    case Tesla.get(url) do
      {:error, %Mint.TransportError{reason: :nxdomain}} ->
        {:error, nil}

      # What's on Chain response
      {:ok, response} ->
        # Convert hex to base64
        base64 = response.body # |> hex_to_base64()

        new_tx = %{
          txid: txid,
          raw: base64,
        }

        Qart.Transactions.create_transaction(new_tx)
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
  end
end
