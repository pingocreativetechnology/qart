defmodule QartWeb.TransactionLive.Show do
  use QartWeb, :live_view

  alias Qart.Transactions

  @impl true
  def mount(_params, _session, socket) do
    utxos = []

    {:ok, assign(socket,
      transaction: nil,
      tx: nil,
      tx_result: nil,
      hex: nil,
      test: 123,
      utxos: utxos
    )}
  end

  @impl true
  # %{"outpoint" => "40860100000000001976a914b3182303bb218b771cc7cbf84d9ddacfbd6180b088ac", "value" => ""}
  def handle_event("create-tx", %{
      "outpoint" => outpoint,
      "txid" => txid,
      "vout" => vout,
      "script" => script,
      "satoshis" => satoshis,
    }, socket) do
    socket = socket
      |> put_flash(:info, "Creating Tx from Output")
      |> push_navigate(to: ~p"/wallet/tx?outpoint=#{outpoint}&txid=#{txid}&vout=#{vout}&script=#{script}&satoshis=#{satoshis}", outpoint2: outpoint )

    {:noreply, socket}
  end

  # When pulling UTXOs, fetch to get transactions.
  # Transaction Outputs can then be marked with when `vout` are unspent
  # These become UTXOs

  @impl true
  def handle_params(%{"id" => id}, _, socket) when byte_size(id) <= 6 do
    transaction = Transactions.get_transaction!(id)
    # Transactions.delete_transaction(transaction)
    {:ok, tx} = BSV.Tx.from_binary(transaction.raw, encoding: :base64) # from junglebus
    # {:ok, tx} = BSV.Tx.from_binary(transaction.rafw, encoding: :hex) # from what's on chain hex
    # {:ok, hex} = nil # tx.raw |> BSV.Tx.from_binary(encoding: :base64)
    hex = nil

    output = tx.outputs |> Enum.at(0)
    chunks = test = output.script.chunks
    test = chunks |> Qart.BSV.ScriptPatterns.is_2sat_ordinal?

    payload = nil
    payload_base64 = nil

    case output.script.chunks |> Qart.BSV.ScriptPatterns.is_2sat_ordinal? do
      {:ok, %{
          json: json,
          payload: payload,
          payload_base64: payload_base64
        }
      } ->
        Qart.debug('going well here')
        false

      false ->
        Qart.debug('also going well here')
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

  def handle_params(%{"id" => txid}, _, socket) when byte_size(txid) == 64 do
    transaction = Transactions.get_transaction_by_txid!(txid)
    {:ok, tx} = BSV.Tx.from_binary(transaction.raw, encoding: :base64) # from junglebus
    # {:ok, tx} = BSV.Tx.from_binary(transaction.rafw, encoding: :hex) # from what's on chain hex
    # {:ok, hex} = nil # tx.raw |> BSV.Tx.from_binary(encoding: :base64)
    hex = nil

    output = tx.outputs |> Enum.at(0)
    chunks = test = output.script.chunks
    # test = chunks |> Enum.at(0)
    test = chunks |> Qart.BSV.ScriptPatterns.is_2sat_ordinal?

    payload = nil
    payload_base64 = nil

    case output.script.chunks |> Qart.BSV.ScriptPatterns.is_2sat_ordinal? do
      {:ok, %{
          json: json,
          payload: payload,
          payload_base64: payload_base64
        }
      } ->
        Qart.debug('going well here')

       false ->
        Qart.debug('also going well here')
        false
    end

     {:noreply,
         socket
         |> assign(:page_title, page_title(socket.assigns.live_action))
         |> assign(:transaction, transaction)
         |> assign(:tx, tx)
         |> assign(:hex, hex)
         |> assign(:test, test)
         |> assign(:payload, payload)
         |> assign(:payload_base64, payload_base64)
        }

  end

  defp page_title(:show), do: "Show Transaction"
  defp page_title(:edit), do: "Edit Transaction"
end
