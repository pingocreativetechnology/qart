defmodule QartWeb.WalletLive do
  use QartWeb, :live_view
  alias Qart.Wallet.WalletSession
  alias Qart.Accounts
  alias BSV.Contract.{P2PKH, OpReturn}

  @impl true
  def mount(_params, session, socket) do
    user = socket.assigns.current_user |> Accounts.maybe_compute_display_name
    user_id = socket.assigns.current_user.id
    wallets = Accounts.get_user_wallets(user_id)
    default_wallet_id = user.default_wallet_id

    # TODO: Fix the flow for the user's first wallet
    # this implementation assumes a wallet.
    # but the user should get to an empty state, and be able to generate or restore a wallet.
    first_wallet = if wallets |> length == 0 do
      {:ok, wallet, _} = WalletSession.generate_wallet(user_id)
      {:ok, updated_user} = Qart.Accounts.set_default_wallet(user, wallet.id)
      wallet
    else
      wallet = Qart.Accounts.get_user_wallet(user_id, default_wallet_id)
    end

    # wallet_id = socket.assigns.current_user.default_wallet_id
    default_wallet = first_wallet
    wallet = default_wallet

    addresses = Qart.Accounts.get_wallet_addresses(wallet.id)
    addresses = Enum.filter(addresses, fn a -> a end)
    address = Enum.at(addresses, 0, nil) # return the first address or nil

    {:ok, to_address} = address.address |> BSV.Address.from_string
    {:ok, change_address} = addresses |> Enum.at(1) |> Map.get(:address)|> BSV.Address.from_string

    derivation_path = "m/44'/236'/0'/0/0"

     # TX Builder
    case WalletSession.derive_keypair(wallet.id, derivation_path) do
      {:ok, keypair} ->
        inputs = [
          # P2PKH.unlock(utxo, %{keypair: keypair})
        ]

        # All sorts of different data patterns can go here
        #
        # This is a basic transaction that sends coins `to_address` AND change (unspent satoshis) back to `change_address`

        # This transaction's OP_RETURN output is prunable because it holds 0 satoshis
        outputs = Qart.BSV.standard_transaction_with_change_outputs(to_address, change_address, [
          "hello",
          "world"
        ])

        # Translate to BSV.UTXO params
        utxos2 = Qart.Transactions.list_utxos
        utxos = utxos2 |> Enum.map(fn utxo ->
          Qart.Transactions.Utxo.to_bsv_utxo(utxo)
        end)

        # given a UTXO (txid, vout), get the corresponding Transaction(txid) Output[vout]

        tx_builder = %BSV.TxBuilder{
          inputs: inputs,
          outputs: outputs
        }

        words = Enum.map(0..11, fn _ -> " " end) # 12 blank words in an array

        transactions = Qart.Transactions.list_transactions
        transaction = Qart.Transactions.list_transactions |> Enum.at(0)

        {:ok, assign(socket,
          content: "",
          encrypted: false,
          address: address, # Ecto object
          address_string: to_address |> BSV.Address.to_string, # string
          addresses: addresses,
          bsv_address: to_address, # BSV object
          current_derivation: nil,
          contract_validation_error: nil,
          default_wallet: default_wallet,
          default_wallet_id: default_wallet_id,
          derivation_path: derivation_path,
          editing_derivation_path: false,
          json: nil,
          mnemonic: nil,
          mnemonic_shown: false,
          outputs: outputs,
          show_add_input: false,
          show_restore_wallet_form: false,
          # satoshis: nil,
          total_wallet_satoshis: 0,
          transactions: transactions,
          transaction: transaction,
          tx: nil,
          tx_builder: tx_builder,
          user: user,
          user_id: user_id,
          utxos: utxos,
          utxos2: utxos2,
          valid_contract: false,
          valid_contract2: false,
          version: 1,
          wallet: wallet,
          wallet_id: wallet.id,
          wallets: wallets,
          wallet_last_synced_at: DateTime.utc_now() |> DateTime.add(-3 * 60 * 60, :second), #
          words: words,
          show_wallet_name_editing: false,

          # Modal
          show_modal: false,
          selected_tx: nil
        )}

      _ ->
        Qart.debug("Wallet can't be derived")
    end
  end

  # used for any Wallet - /wallets/:id
  def handle_params(%{"id" => wallet_id}, _uri, socket) do
    user_id = socket.assigns.current_user.id
    wallet = Accounts.get_user_wallet(user_id, wallet_id)
    addresses = Qart.Accounts.get_wallet_addresses(wallet.id)
    addresses = Enum.filter(addresses, fn a -> a end)
    address = addresses |> Enum.at(0)

    case wallet do
      %Qart.Wallet.Wallet{} ->
        {:noreply, assign(socket,
          wallet: wallet,
          addresses: addresses
        )
        }

      _ ->
        socket = socket
        |> put_flash(:error, "Wallet #{wallet_id} not found")
        |> push_navigate(to: ~p"/wallets" )

        {:noreply, assign(socket, wallet: nil)}
    end
  end

  # used for Active Wallet - /wallet
  @impl true
  def handle_params(params, _uri, socket) do
    wallet = socket.assigns.default_wallet
    addresses = Qart.Accounts.get_wallet_addresses(wallet.id)
    address = Enum.at(addresses, 0, nil)
    {:ok, bsv_address} = address.address |> BSV.Address.from_string

    socket =
      case socket.assigns.live_action do
        :index ->
          socket

        :tx ->
          socket

        :easy ->
          socket

        :show ->
          socket
          # assign(socket, :wallet, Repo.get!(Wallet, params["id"]))

        :utils ->
          # assign(socket, :stats, compute_wallet_stats())
          socket
      end

    {:noreply, assign(socket,
      bsv_address: bsv_address,
      wallet: wallet,
      addresses: addresses
    )}
  end

  # @impl true
  # this tells Phoenix to look for the template matching the action
  # def render(assigns) do
  #   IO.puts(assigns.live_action)
  #   Phoenix.View.render(QartWeb.WalletLive, "#{assigns.live_action}.html", assigns)
  # end

  def handle_event("generate-mnemonic", _, socket) do
    mnemonic = BSV.Mnemonic.new()
    seed = BSV.Mnemonic.to_seed(mnemonic)
    extkey = BSV.ExtKey.from_seed!(seed)
    derivation_path = "m/44/0/0/1"
    child = BSV.ExtKey.derive(extkey, derivation_path)
    address = BSV.Address.from_pubkey(child.pubkey)
    address_string = BSV.Address.to_string(address)
    socket =
      socket
      |> assign(mnemonic: mnemonic)
      |> assign(derivation_path: derivation_path)
      |> assign(address_string: address_string)
    {:noreply, socket}
  end

  def handle_event("get-txid", %{"txid" => txid}, socket) do
    # case Qart.Transactions.get_tx(txid) do
    case Qart.WhatsOnChain.get_tx(txid) do
      {:error, nil} ->
        {:noreply, put_flash(socket, :error, "Cannot get TXID address when offline")}

       {:ok, json} ->
        json = json.raw
        {:noreply, assign(socket, json: json)}
    end

  end

  def handle_event("update-wallet-name", %{"name" => name}, socket) do
    {:ok, updated_wallet} = Qart.Accounts.update_wallet_name(socket.assigns.wallet, %{name: name})
    id = updated_wallet.id

    updated_wallets =
      Enum.map(socket.assigns.wallets, fn
        %{id: ^id} -> updated_wallet
        other -> other
      end)

    {:noreply, assign(socket, wallet: updated_wallet, wallets: updated_wallets, show_wallet_name_editing: false)}
  end

  def handle_event("generate_mnemonic", _, socket) do
    mnemonic = BSV.Mnemonic.new()
    {:noreply, assign(socket, mnemonic: mnemonic)}
  end

  def handle_event("showWalletNameEditing", _, socket) do
    show_wallet_name_editing = socket.assigns.show_wallet_name_editing
    {:noreply, assign(socket, show_wallet_name_editing: !show_wallet_name_editing)}
  end

  # RESTORE A WALLET
  @impl true
  def handle_event("show_restore_wallet_form", _, socket) do
    {:noreply, assign(socket, show_restore_wallet_form: true)}
  end

  @impl true
  def handle_event("hide_restore_wallet_form", _, socket) do
    {:noreply, assign(socket, show_restore_wallet_form: false)}
  end

  @impl true
  def handle_event("restore_wallet", %{"words" => words_params}, socket) do
    words = Map.values(words_params) |> Enum.map(&String.trim/1)
    mnemonic = Enum.join(words, " ")

    # Validate the mnemonic here, if needed
    IO.inspect(mnemonic, label: "Submitted Mnemonic")

    case WalletSession.restore_wallet(socket.assigns.user_id, mnemonic) do
      {:ok, wallet, mnemonic} ->
        socket = socket |> put_flash(:info, "Wallet restored successfully")
        {:noreply, assign(socket, wallet: wallet, mnemonic: mnemonic, wallets: socket.assigns.wallets ++ [wallet])}

      {:ok, wallet} ->
        {:noreply, assign(socket, wallet: wallet, wallets: socket.assigns.wallets ++ [wallet])}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to generate wallet")}
    end
  end

  @impl true
  def handle_event("fill_test_mnemonic", _, socket) do
    test_12_words = System.get_env("TEST_12_WORDS")
    word_array = String.split(test_12_words, " ")

    {:noreply, assign(socket, words: word_array)}
  end

  ### NEW WALLET STUFF
  @impl true
  def handle_event("generate_wallet", _params, socket) do

    case WalletSession.generate_wallet(socket.assigns.user_id) do
      {:ok, wallet, mnemonic} ->
        socket = socket |> put_flash(:info, "Wallet generated successfully")
        {:noreply, assign(socket, wallet: wallet, mnemonic: mnemonic, wallets: socket.assigns.wallets  ++ [wallet])}

      {:ok, wallet} ->
        {:noreply, assign(socket, wallet: wallet, wallets: socket.assigns.wallets  ++ [wallet])}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to generate wallet")}
    end
  end

  def handle_event("reveal_mnemonic", _params, socket) do
    {:noreply, assign(socket, mnemonic_shown: true)}
  end

  def handle_event("clear_wallet", _params, socket) do
    WalletSession.clear_wallet()
    {:noreply, assign(socket, wallet: nil)}
  end

  def handle_event("derive_address", _params, socket) do
    case WalletSession.derive_new_address(socket.assigns.wallet.id) do
      {:ok, new_address, wallet} ->
        new_address = new_address |> Qart.Accounts.preload_utxos
        updated_addresses = socket.assigns.addresses ++ [new_address]

        # wallet = socket.assigns.wallet
        # wallet = %{wallet | current_derivation: wallet.current_derivation}

        {:noreply, assign(socket, addresses: updated_addresses,
          wallet: wallet,
          current_derivation: wallet.current_derivation)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to derive address")}
    end
  end

  def handle_event("delete_wallet", _params, socket) do
    wallet = socket.assigns.wallet
    Qart.Accounts.delete_wallet(wallet)

    socket = put_flash(socket, :info, "Wallet deleted")
      |> push_navigate(to: ~p"/wallets" )
    {:noreply, assign(socket, wallet: nil)}
  end

  def handle_event("make_wallet_active", _params, socket) do
    wallet = socket.assigns.wallet
    user = socket.assigns.current_user
    {:ok, updated_user} = Qart.Accounts.set_default_wallet(user, wallet.id)

    socket = socket
      |> assign(default_wallet: wallet)
      |> assign(default_wallet_id: wallet.id)
      |> put_flash(:info, "Wallet #{wallet.id} is now the default Wallet")

    {:noreply, socket}
  end

  def handle_event("call_junglebus", %{"txid" => txid}, socket) do
    json = Qart.WhatsOnChain.call_junglebus(txid)
    {:noreply, socket}
  end

  def handle_event("sync-tx", %{"address" => address}, socket) do
    case Qart.WhatsOnChain.get_address(address) do
      {:error, nil} ->
        {:noreply, put_flash(socket, :error, "Cannot sync address when offline")}

      {:ok, response} ->
        {:ok, response}

       _ ->
        {:noreply, socket}
    end
  end

  def handle_event("get-utxos", %{"address" => address}, socket) do
    case Qart.WhatsOnChain.get_address_utxos(address) do
      {:error, nil} ->
        {:noreply, put_flash(socket, :error, "Cannot sync address when offline")}

      {:ok, response} ->

        # response = %{
        #   "address" => "mpVjxzWwqLSgMnD2a6sfq64q24Vk2LTkBa",
        #   "error" => "",
        #   "result" => [
        #     %{
        #       "hex" => "76a914627e6cb63c8759336b39784d75b3f328c65f5b6088ac",
        #       "isSpentInMempoolTx" => false,
        #       "status" => "unconfirmed",
        #       "tx_hash" => "31dfaa860debd39af28776d1037e0c76980a5c9d844db06c188122f1aa3c93a7",
        #       "tx_pos" => 0,
        #       "value" => 99904
        #     }
        #   ],
        #   "script" => "9eb2c075dec7e794c54b6113ee3fb020b75fb8fbe8c91e4f6f7cc6b60f5ce9c1"
        # }

        %{
          "address" => address,
          "script" => script_string, # scripthash
          "result" => results
        } = response


        # get the transaction
        # find the N vout
        # return the vout
        # get the hex from the vout

        x = script_string |> BSV.Script.from_binary(encoding: :hex)

        for result <- results do
          q = %{
            script: "",
            spent: result["isSpentInMempoolTx"],
            # status: result["status"],
            txid: result["tx_hash"],
            vout: result["tx_pos"],
            satoshis: result["value"],
            address: address,
          }
          Qart.Transactions.create_utxo(q)
        end

        # Write these results to the UTXOs table
        satoshis = Enum.reduce(results, 0, fn result, acc -> acc + result["value"] end)

        {:noreply, assign(socket, response: response, satoshis: satoshis)}

       _ ->
        {:noreply, socket}
    end
  end


    # For Available Inputs / aka Spendable Outputs...
  # TODO: Associate the UTXO to a valid KeyPair / Derivation path

  def handle_params(params = %{"outpoint" => outpoint, "txid" => txid, "vout" => vout, "script" => script, "satoshis" => satoshis}, _uri, socket) do
    # vout_as_int = Integer.parse("3")

    params2 = %{
      "outpoint" => outpoint,
      "txid" => txid,
      "vout" => vout_as_int,
      "script" => script,
      "satoshis" => satoshis
    } = params
    {:ok, utxo} = BSV.UTXO.from_params(params2)

    keypair = BSV.KeyPair.new()
    contract = P2PKH.unlock(utxo, %{keypair: keypair})

    new_inputs = socket.assigns.tx_builder.inputs ++ [contract]

    tx_builder = %BSV.TxBuilder{
      inputs: new_inputs,
      outputs: socket.assigns.outputs
    }

    {:noreply, assign(socket,
      tx_builder: tx_builder,
      tx: "nil",
      show_add_input: false)
    }
  end

  def handle_event("update_satoshis", %{"value" => satoshis, "vout" => vout}, socket) do
    # handle nil satoshis
    satoshis = case satoshis do
      "" ->
        0

      satoshis ->
        String.to_integer(satoshis)
    end

    idx = String.to_integer(vout)
    new_outputs = List.update_at(socket.assigns.tx_builder.outputs, idx, fn out ->
      %{out | subject: satoshis}
    end)

    tx_builder = %BSV.TxBuilder{
      inputs: socket.assigns.tx_builder.inputs,
      outputs: new_outputs
    }
    tx = BSV.TxBuilder.to_tx(tx_builder)

    {:noreply, assign(socket, tx_builder: tx_builder, tx: tx)}
  end

  def handle_event("update-output", %{"value" => text, "vout" => vout}, socket) do
    idx = String.to_integer(vout)

    output = socket.assigns.tx_builder.outputs |> Enum.at(idx)
    satoshis = output.subject

    case address = BSV.Address.from_string(text) do
      {:error, :invalid_address} ->
        Qart.debug("got invalid address #{text}")
        {:noreply, socket}

      {:ok, address = %BSV.Address{}} ->
        Qart.debug("got address")
        new_output = P2PKH.lock(satoshis, %{address: address})

        new_outputs = List.update_at(socket.assigns.tx_builder.outputs, idx, fn out ->
          new_output
        end)

        tx_builder = %BSV.TxBuilder{
          inputs: socket.assigns.tx_builder.inputs,
          outputs: new_outputs
        }
        tx = BSV.TxBuilder.to_tx(tx_builder)

        {:noreply, assign(socket, tx_builder: tx_builder, tx: tx)}

      x ->
        Qart.debug(x)
    end
  end

  def handle_event("update-opreturn", %{"value" => text, "vout" => vout}, socket) do
    idx = String.to_integer(vout)

    opreturn_data = text |> String.split(" ")
    output = socket.assigns.tx_builder.outputs |> Enum.at(idx)
    satoshis = output.subject

    new_output = OpReturn.lock(satoshis, %{data: opreturn_data})
    new_outputs = List.update_at(socket.assigns.tx_builder.outputs, idx, fn out ->
      new_output
    end)

    tx_builder = %BSV.TxBuilder{
      inputs: socket.assigns.tx_builder.inputs,
      outputs: new_outputs
    }
    tx = BSV.TxBuilder.to_tx(tx_builder)

    {:noreply, assign(socket, tx_builder: tx_builder, tx: tx, outputs: new_outputs)}
  end

  def handle_event("delete-output", %{"value" => vout}, socket) do
    idx = String.to_integer(vout)
    # List.delete_at(socket.assigns.outputs, idx) |> Qart.debug
    new_outputs = List.delete_at(socket.assigns.tx_builder.outputs, idx)

    new_outputs |> Qart.debug

    tx_builder = %BSV.TxBuilder{
      inputs: socket.assigns.tx_builder.inputs,
      outputs: new_outputs
    }
    tx = BSV.TxBuilder.to_tx(tx_builder)

    {:noreply, assign(socket, tx_builder: tx_builder, tx: tx, outputs: new_outputs)}
  end

  def handle_event("add_output", %{"output-type" => output_type_requested}, socket) do

    # based on the new output button clicked, create a custom output
    new_output = case output_type_requested do

      "p2pkh" ->
        {:ok, address} = socket.assigns.address.address |> BSV.Address.from_string
        P2PKH.lock(999, %{address: address})

      "op_return" ->
        OpReturn.lock(0, %{data: [
          "hello",
          "world2"
        ]})

      "one_sat" ->
        OpReturn.lock(1, %{data: [
          "i am a 1sat ordinal",
          '{"json" : "object", "relatedItems" : [{ name: "test", price: 123.00}, { name: "toast", price: "9.87" }]}'
        ]})

      "bitcoin_schema" ->
        OpReturn.lock(10, %{data: [
          "bitcoin schema",
          "object"
        ]})

      "twetch_post" ->
        OpReturn.lock(10000, %{data: [
          "TWETCH POST"
        ]})

      "custom" ->
        OpReturn.lock(123, %{data: [
          "CUSTOM ALL DAY"
        ]})

      "brc_20" ->
        OpReturn.lock(1, %{data: [
          '{ "p": "brc-20", "op": "mint", "tick": "meme", "amt": "1" }'
        ]})

      "one_sat_html_inscription" ->
          OpReturn.lock(1, %{data: [
            "1SAT_P2PKH",
            :OP_IF,
            "ord",
            :OP_1,
            "text/html;charset=utf8",
            :OP_0,
            "<html><body>☀️</body></html>",
            :OP_ENDIF
          ]})

    end

    updated_outputs = socket.assigns.tx_builder.outputs ++ [new_output]

    tx_builder = %BSV.TxBuilder{
      inputs: socket.assigns.tx_builder.inputs,
      outputs: updated_outputs
    }

    tx = BSV.TxBuilder.to_tx(tx_builder)

    {:noreply, assign(socket,
      tx: tx,
      tx_builder: tx_builder
      )
    }
  end

  def handle_event("broadcastTx", params, socket) do
    tx_result = socket.assigns.tx |> BSV.Tx.to_binary(encoding: :hex)
    z = Qart.WhatsOnChain.broadcast_raw_transaction_hex(tx_result)
    Qart.debug(z)
    {:noreply, socket}
  end

  def handle_event("select-utxo", %{"txid" => search_txid, "vout" => vout}, socket) do
    # TODO:
    # find Wallet derivation path for a given pubkey hash b3182303bb218b771cc7cbf84d9ddacfbd6180b0
    # Wallet.get_address_by_pubkey_hash("b3182303bb218b771cc7cbf84d9ddacfbd6180b0")
    # Address, address, derivation path, pubkeyhash
    {:ok, keypair} = WalletSession.derive_keypair(socket.assigns.wallet.id, socket.assigns.address.derivation_path)
    # get the correct keypair from the wallet.
    # this could be by derivation path. this could be by looking at the script, finding the
    # type and argument values it requires, and querying the wallet

    selected_utxo = Enum.find(socket.assigns.utxos, fn utxo ->
      txid = utxo.outpoint |> BSV.OutPoint.get_txid
      txid == search_txid
    end)

    new_input = P2PKH.unlock(selected_utxo, %{keypair: keypair})
    updated_inputs = socket.assigns.tx_builder.inputs ++ [new_input]

    tx_builder = %BSV.TxBuilder{
      inputs: updated_inputs,
      outputs: socket.assigns.tx_builder.outputs
    }

    tx = BSV.TxBuilder.to_tx(tx_builder)

    {:noreply, assign(socket,
      tx_builder: tx_builder,
      tx: tx
      )
    }
  end

  # Remove a UTXO from inputs
  def handle_event("unselect-utxo", %{"txid" => search_txid, "vout" => vout}, socket) do
    # selected_utxo = Enum.find(socket.assigns.tx_builder.inputs, fn contract ->
    #   txid = contract.subject.outpoint |> BSV.OutPoint.get_txid
    #   txid == search_txid
    # end)

    # The Proper thing to do here is:
    # Update socket UTXOs
    # Then populate the objects from them in a standard-ish way
    updated_inputs = Enum.reject(socket.assigns.tx_builder.inputs, fn contract ->
      Enum.any?(socket.assigns.tx_builder.inputs, fn
        contract ->
          contract_txid = contract.subject.outpoint |> BSV.OutPoint.get_txid
          contract_txid == search_txid

          _ -> false end
        )
      end)

    tx_builder = %BSV.TxBuilder{
      inputs: updated_inputs,
      outputs: socket.assigns.tx_builder.outputs
    }

    {:noreply, assign(socket,
      tx_builder: tx_builder
      )
    }
  end

  def handle_event("add-input", _params, socket) do
    keypair = BSV.KeyPair.new


    utxo = BSV.UTXO.from_params!(%{
      "txid" => "5e3014372338f079f005eedc85359e4d96b8440e7dbeb8c35c4182e0c19a1a12",
      "vout" => "1",
      "satoshis" => "123001",
      "script" => "e01cccd61cd2a18101172ec0d0bc6f3fe63236dbc052fa6058b4949bc4fc5a94"
    })
    # Qart.debug("utxo from INPUTutxo from INPUTutxo from INPUTutxo from INPUTutxo from INPUT")
    # Qart.debug(socket.assigns.utxos)
    # utxo =

    # utxo from INPUT

    # TODO: sign with which key?
    # Choose from a dropdown of wallet keys / addresses
    new_input = P2PKH.unlock(utxo, %{keypair: keypair})

    updated_inputs = socket.assigns.tx_builder.inputs ++ [new_input]

    tx_builder = %BSV.TxBuilder{
      inputs: updated_inputs,
      outputs: socket.assigns.tx_builder.outputs
    }

    tx = BSV.TxBuilder.to_tx(tx_builder)

    {:noreply, assign(socket,
      tx: tx,
      tx_builder: tx_builder
      )
    }
  end

  def handle_event("delete-input", %{"value" => txid, "vout" => vout}, socket) do
    idx = String.to_integer(vout)
    updated_inputs = List.delete_at(socket.assigns.tx_builder.inputs, idx)

    tx_builder = %BSV.TxBuilder{
      inputs: updated_inputs,
      outputs: socket.assigns.tx_builder.outputs
    }

    tx = BSV.TxBuilder.to_tx(tx_builder)

    {:noreply, assign(socket,
      tx_builder: tx_builder,
      tx: tx
      )
    }
  end

  def handle_event("edit-derivation-path", _params, socket) do
    {:noreply, assign(socket,
      editing_derivation_path: true
      )
    }
  end

  def handle_event("save-derivation-path", %{"segments" => %{"0" => slot_0, "1" => slot_1, "2" => slot_2, "3" => slot_3, "4" => slot_4}} = params, socket) do
    derivation_path = "m/#{slot_0}/#{slot_1}/#{slot_2}/#{slot_3}/#{slot_4}"
    {:noreply, assign(socket,
      derivation_path: derivation_path,

      editing_derivation_path: false
      )
    }
  end

  def handle_event("show-add-input", _params, socket) do
    {:noreply, assign(socket,
      show_add_input: true
      )
    }
  end

  def handle_event("hide-add-input", _params, socket) do
    {:noreply, assign(socket,
      show_add_input: false
      )
    }
  end

  # Update the content as the user types.
  def handle_event("update_content", %{"content" => content}, socket) do
    {:noreply, assign(socket, content: content)}
  end

  # Updates a specific input's content based on its ID.
  # def handle_event("update_input", %{"id" => id, "content" => content}, socket) do
  #   id = String.to_integer(id)
  #   inputs =
  #     Enum.map(socket.assigns.inputs, fn input ->
  #       if input.id == id, do: %{input | content: content}, else: input
  #     end)
  #   {:noreply, assign(socket, inputs: inputs)}
  # end

  # Handles checked checkbox
  def handle_event("toggle_encryption", %{"encrypted" => value}, socket) do
    encrypted = value == "on"
    {:noreply, assign(socket, encrypted: encrypted)}
  end

  # Handles unchecked checkbox
  def handle_event("toggle_encryption", _, socket) do
    {:noreply, assign(socket, encrypted: false)}
  end


  # Calls a function to create a transaction from all inputs.
  # def handle_event("create_tx", _params, socket) do
  #   tx = TxCreator.create_transaction(socket.assigns.inputs)
  #   {:noreply, assign(socket, tx: tx)}
  # end

  def handle_event("update_outputs", params, socket) do
    {:noreply, socket}
  end


  # Handle the "clickwrap" event: encrypt if needed and generate an unsigned BSV transaction.
  def handle_event("clickwrap", params, socket) do

    # Get the Keypair from the Wallet for a Derivation path, then sign the transaction
    case WalletSession.derive_keypair(socket.assigns.wallet.id, socket.assigns.address.derivation_path) do
      {:ok, keypair} ->
        # Create an unsigned BSV transaction
        tx_builder = socket.assigns.tx_builder

        tx = BSV.TxBuilder.to_tx(tx_builder)

        {:noreply, assign(socket,
          tx_builder: tx_builder,
          tx: tx
        )}

      {:error, reason} ->
        Qart.debug(reason)
    end
  end

  def handle_event("sync-address", %{"address" => address}, socket) do
    {:ok, utxos} = Qart.Wallet.Sync.loop_addresses_for_utxos
    {:noreply, assign(socket, wallet_last_synced_at: DateTime.utc_now())}
  end

  def handle_event("validate", _, socket) do
    keypair = BSV.KeyPair.new()
    lock_params = %{address: BSV.Address.from_pubkey(keypair.pubkey)}

    keypair2 = BSV.KeyPair.new()
    unlock_params = %{keypair: keypair2}

    case BSV.Contract.simulate(P2PKH, lock_params, unlock_params) do
      {:ok, vm} ->
        valid_contract = BSV.VM.valid?(vm)
        {:noreply, assign(socket, valid_contract: valid_contract)}

      {:error, x }  ->
        {:noreply, assign(socket, valid_contract: false, contract_error: x.error)}
    end

  end

  def handle_event("validate2", _, socket) do
    wallet = socket.assigns.wallet
    address = Qart.Accounts.get_address_keypair(wallet.id, socket.assigns.address.address)

    {:ok, bsv_address} = BSV.Address.from_string(address.address)
    {:ok, keypair} = WalletSession.derive_keypair(wallet.id, address.derivation_path)
    lock_params = %{address: bsv_address}
    unlock_params = %{keypair: keypair}

    # case BSV.Contract.simulate(BSV.Contract.OneSatOrdinal, one_sat_ordinal_lock_params, one_sat_ordinal_lock_params) do
    # end

    # case BSV.Contract.simulate(BSV.Contract.CustomContract, custom_lock_params, custom_unlock_params) do
    # end

    case BSV.Contract.simulate(P2PKH, lock_params, unlock_params) do
      {:ok, vm} ->
        valid_contract2 = BSV.VM.valid?(vm)
        {:noreply, assign(socket, valid_contract2: valid_contract2)}

      {:error, x }  ->
        {:noreply, assign(socket, valid_contract2: false, contract_validation_error: x.error, contract_error: x.error)}
    end
  end

  @impl true
  def handle_event("open_modal", %{"id" => id}, socket) do
    tx = Enum.find(socket.assigns.transactions, fn tx -> to_string(tx.id) == id end)
    {:noreply, assign(socket, show_modal: true, selected_tx: tx)}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  # DATA
  def utxos do
    woc_utxos = [
      %{
        "height" => 1670369,
        "isSpentInMempoolTx" => false,
        "status" => "confirmed",
        "tx_hash" => "b271746bd31acbf6fc251e5ea52dde450d6870392e70875bbf98409684f62c0b",
        "tx_pos" => 0,
        "value" => 99904,
        # From the What's on Chain Transaction's endpoint
        "script" => "483045022100961a850e484a3167b1dc9f59648947c69fca307eb1f143214bb0e662f7d9467202200efa2b1ac4a93dff58d2ebcc88ae1ef4ebfaa827722900eb31fa2036bf8c6eb841210292acdb57c788c1e8c83cdb0ae8f23e079139ba7ba1bccf67b31653c7af12c4b4"
      },
      %{
        "height" => 1670503,
        "isSpentInMempoolTx" => false,
        "status" => "confirmed",
        "tx_hash" => "64021d4a8d90d55f47f5123e1b0190041349a72a38c6e6ff8fabf5867547f9a9",
        "tx_pos" => 0,
        "value" => 99904,
        "script" => "483045022100b563678b312f174bb76cd12843dbd33f39f3ea4bb10a1e4fd2e4c25e4fef4e75022022eed1e07967613e04797d33bbffecb001edefab422ede388176482f1eb3bd2941210292acdb57c788c1e8c83cdb0ae8f23e079139ba7ba1bccf67b31653c7af12c4b4"
      }
    ]

    # do something to store and/or lookup transactions

    # find for local transaction by txid
    # if not, call an API to get a json response. use the response to create the local transaction
    # and then find local transaction by txid

    # Translate to BSV.UTXO params
    utxos = Enum.map(woc_utxos, fn utxo ->
      %{
        "height" => _,
        "isSpentInMempoolTx" => _,
        "status" => _,
        "tx_hash" => txid,
        "tx_pos" => vout,
        "value" => satoshis,
        "script" => script_hex
      } = utxo

      bsv_utxo_params = %{
        "txid" => txid,
        "vout" => vout,
        "satoshis" => satoshis,
        "script" => script_hex
      }

      BSV.UTXO.from_params!(bsv_utxo_params)
    end)

    # given a UTXO (txid, vout), get the corresponding Transaction(txid) Output[vout]

    utxos2 = Qart.Transactions.list_utxos

    utxos = utxos2 |> Enum.map(fn utxo ->
      Qart.BSV.to_bsv_utxo(utxo)
    end)

    utxos
  end










end
