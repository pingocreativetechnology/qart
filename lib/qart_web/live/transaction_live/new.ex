defmodule QartWeb.TransactionLive.New do
  use QartWeb, :live_view

  alias Qart.Transactions

  @impl true
  def mount(_params, _session, socket) do
    utxos = []

    {:ok, assign(socket,
      transaction: nil,
      tx: nil,
      hex: nil,
      test: 123,
      raw_tx: "",
      utxos: utxos
    )}
  end

  def handle_event("generateTx", %{"value" => ""}, socket) do
    {:noreply, socket}
  end

  def handle_event("generateTx", %{"value" => raw_tx}, socket) do
    tx = BSV.Tx.from_binary(raw_tx, encoding: :hex)

    case BSV.Tx.from_binary(raw_tx, encoding: :hex) do
      {:error, {:invalid_encoding, :hex}} ->
        "errrr"

        {:noreply, socket}

      {:ok, tx} ->
        "do this with tx"

        {:noreply, assign(socket,
            raw_tx: raw_tx,
            tx: tx
          )
        }
    end
  end

  # When pulling UTXOs, fetch to get transactions.
  # Transaction Outputs can then be marked with when `vout` are unspent
  # These become UTXOs

  @impl true
  def handle_params(%{"id" => id}, _, socket) when byte_size(id) <= 6 do
    transaction = Transactions.get_transaction!(id)
    {:ok, tx} = BSV.Tx.from_binary(transaction.raw, encoding: :base64) # from junglebus
    hex = nil

    output = tx.outputs |> Enum.at(0)
    chunks = test = output.script.chunks
    test = chunks |> Qart.BSV.ScriptPatterns.is_2sat_ordinal?

    payload = nil
    payload_base64 = nil

    case output.script.chunks |> Qart.BSV.ScriptPatterns.is_2sat_ordinal? do
      {:ok, :one_sat, %{
          json: json,
          payload: payload,
          payload_base64: payload_base64
        }
      } ->
        false

      false ->
        false
    end

    utxos = []

     {:noreply,
         socket
         |> assign(:page_title, page_title(socket.assigns.live_action))
         |> assign(:transaction, transaction)
         |> assign(:tx, tx)
         |> assign(:hex, hex)
         |> assign(:test, test)
         |> assign(:utxos, utxos)
         |> assign(:payload, payload)
         |> assign(:payload_base64, payload_base64)
        }

  end

  def handle_params(%{}, _, socket) do
    raw_tx = "AQAAAAGdc4HzIjiUDXsB2EuqIuaOnFYT573EXOtMLtwwECqXShkAAABrSDBFAiEA8izqhtwVTU8f5L4rzJ6FQQIv/Mw8JaY9i3ajUYntJfsCIE+TmyB+1rDPGvDXYHEjqk0p28lbpJvMBuJzr7J3iR2VQSECkqzbV8eIwejIPNsK6PI+B5E5unuhvM9nsxZTx68SxLT/////AUCGAQAAAAAAGXapFC8nilXPH7Z1ChbNcBkGXQZoWBlkiKwAAAAA"

    raw_tx_2 = "0100000001a7933caaf12281186cb04d849d5c0a98760c7e03d17687f29ad3eb0d86aadf31000000006b483045022100831f7da8125e1b48347007100bfeed96a258537d8652765e0992b8539993254102200bcfa579389f209cdd1f49fc1f755fc64ad545d04ff1ef79a2093f0c36d5181c41210218477d2216247499e54a117933ef9841860ae5c9bad3ab45ebb314a768d373ebffffffff0310270000000000001976a914365bd10a1ac118ce2a42f700ba7a1043e2cf10d588ac10270000000000001976a914384e8ad44dc46f96f15fd6e11f7c7b9d1589144588ac00000000000000000e006a0568656c6c6f05776f726c6400000000"

    {:ok, tx} = BSV.Tx.from_binary(raw_tx, encoding: :base64)
    {:noreply, assign(socket, transaction: tx, tx: tx)}
  end

  defp page_title(:show), do: "Show Transaction"
  defp page_title(:edit), do: "Edit Transaction"

end
