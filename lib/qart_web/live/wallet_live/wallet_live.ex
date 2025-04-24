defmodule QartWeb.WalletLive do
  use QartWeb, :live_view
  alias Qart.Wallet.WalletSession
  alias Qart.Accounts
  alias BSV.Contract.{P2PKH, OpReturn}

  def mount(_params, session, socket) do
    user = socket.assigns.current_user |> Accounts.maybe_compute_display_name
    user_id = socket.assigns.current_user.id
    wallets = Accounts.get_user_wallets(user_id)
    wallet_id = socket.assigns.current_user.default_wallet_id
    wallet = Qart.Accounts.get_user_wallet(user_id, wallet_id)
    addresses = Qart.Accounts.get_wallet_addresses(wallet.id)

    addresses = Enum.filter(addresses, fn a -> a end)
    # [] = addresses
    [address | _] = addresses
    # case addresses do
    #   [address | _] = addresses

    #   [] = addresses
    # end

    {:ok, to_address} = BSV.Address.from_string "mpVjxzWwqLSgMnD2a6sfq64q24Vk2LTkBa" # TEST m/44'/236'/0'/0/2
    {:ok, change_address} = BSV.Address.from_string "mpVjxzWwqLSgMnD2a6sfq64q24Vk2LTkBa" # TEST m/44'/236'/0'/0/2
    # TEST m/44'/236'/0'/0/1
    # {:ok, change_address} = address.address |> BSV.Address.from_string
    derivation_path = "m/44'/236'/0'/0/1"

     # TX Builder
    case WalletSession.derive_keypair(wallet.id, derivation_path) do
      {:ok, keypair} ->

        inputs = if Map.has_key?(socket.assigns, :inputs) do
          socket.assigns.inputs
        else
          [
            # P2PKH.unlock(utxo, %{keypair: keypair}),
          ]
        end

        # All sorts of different data patterns can go here
        #
        # This is a basic transaction that sends coins `to_address` AND change (unspent satoshis) back to `change_address`
        outputs = [
          P2PKH.lock(10000, %{address: to_address}),
          P2PKH.lock(10000, %{address: change_address}),
          OpReturn.lock(0, %{data: [
            "hello",
            "world"
          ]})
        ]

        # Translate to BSV.UTXO params
        utxos = QartWeb.WalletLive.utxos
        utxos2 = Qart.Transactions.list_utxos

        # given a UTXO (txid, vout), get the corresponding Transaction(txid) Output[vout]

        utxo = utxos |> Enum.at(0)

        tx_builder = %BSV.TxBuilder{
          inputs: inputs,
          outputs: outputs
        }

        words = Enum.map(0..11, fn x -> " " end) # 12 blank words in an array

        transactions = Qart.Transactions.list_transactions
        transaction = Qart.Transactions.list_transactions |> Enum.at(0)

        {:ok, assign(socket,
          content: "",
          default_wallet: wallet,
          default_wallet_id: socket.assigns[:default_wallet_id] || user.default_wallet_id,
          encrypted: false,
          tx_result: nil,
          tx_result_base64: nil,
          # address: address.address,
          # address_string: address.address,
          address: to_address,
          address_string: to_address |> BSV.Address.to_string,
          addresses: addresses,
          derivation_path: derivation_path,
          editing_derivation_path: false,
          valid_contract: false,
          valid_contract2: false,
          inputs: inputs,
          outputs: outputs,
          total_wallet_satoshis: 0,
          mnemonic: nil,
          json: nil,
          next_id: 2,
          current_derivation: nil,
          contract_validation_error: nil,
          mnemonic_shown: false,
          show_add_input: false,
          show_restore_wallet_form: false,
          # satoshis: nil,
          transactions: transactions,
          transaction: transaction,
          tx_builder: tx_builder,
          tx: "nil",
          user: user,
          user_id: user_id,
          utxos: utxos,
          utxos2: utxos2,
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
          Qart.debug("whoooooooooa")
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
          addresses: addresses,
          address: address,
          # default_wallet: wallet
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
    user_id = socket.assigns.current_user.id
    wallet_id = socket.assigns.default_wallet_id
    wallet = Accounts.get_user_wallet(user_id, wallet_id)
    addresses = Qart.Accounts.get_wallet_addresses(wallet.id)
    utxos = QartWeb.WalletLive.utxos

    socket =
      case socket.assigns.live_action do
        :index ->
          socket

        :tx ->
          socket

        :show ->
          socket
          # assign(socket, :wallet, Repo.get!(Wallet, params["id"]))

        :utils ->
          # assign(socket, :stats, compute_wallet_stats())
          socket
      end

    {:noreply, assign(socket,
      wallet: wallet,
      addresses: addresses,
      utxos: utxos
    )}
  end

  # @impl true
  # this tells Phoenix to look for the template matching the action
  # def render(assigns) do
  #   Qart.debug("------------------------------------lllll>")
  #   Qart.debug(assigns.live_action)
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

  def handle_event("toggleUtxo", %{"utxo_id" => id}, socket) do
    utxo_with_selections = Enum.map(socket.assigns.utxos, fn utxo ->
      %{utxo | selected: false }
      # %{utxo | selected: (utxo.id == id) }
    end)

    {:noreply, assign(socket, utxos: utxo_with_selections)}
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
    socket = socket
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
    # utxos = Qart.Transactions.list_utxos_by_address(address)
    # Qart.debug(utxos)

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
          "script" => script_string,
          "result" => results
        } = response


        for result <- results do
          q = %{
            address: address,
            script: script_string,
            spent: result["isSpentInMempoolTx"],
            # hex: result["hex"],
            # status: result["status"],

            txid: result["tx_hash"],
            vout: result["tx_pos"],
            satoshis: result["value"],
          }
          Qart.Transactions.create_utxo(q)
        end


        # Write these results to the UTXOs table

        satoshis = Enum.reduce(results, 0, fn result, acc -> acc + result["value"] end)

        # x = script_string |> BSV.Script.from_binary(encoding: :base64)
        {:ok, y} = script_string |> BSV.Script.from_binary(encoding: :hex)
        {:noreply, assign(socket, response: response, satoshis: satoshis)}

       _ ->
        {:noreply, socket}
    end
  end


    # For Available Inputs / aka Spendable Outputs...
  # TODO: Associate the UTXO to a valid KeyPair / Derivation path

  def handle_params(params = %{"outpoint" => outpoint, "txid" => txid, "vout" => vout, "script" => script, "satoshis" => satoshis}, _uri, socket) do
    # vout = 1 #Integer.parse(vout)
    Qart.debug(params)
    # updated_params = params
    # updated_params = assign(updated_params, vout: 2)

    # %{
    #   "outpoint" => "40860100000000001976a914b3182303bb218b771cc7cbf84d9ddacfbd6180b088ac",
    #   "satoshis" => "99904",
    #   "script" => "76a914b3182303bb218b771cc7cbf84d9ddacfbd6180b088ac",
    #   "txid" => "10",
    #   "vout" => "0"
    # } = params

    vout_as_int = Integer.parse("3")

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
    } end

  def handle_params(%{}, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("update_satoshis", %{"value" => satoshis, "vout" => vout}, socket) do
    # update_ouput_satoshis
    satoshis = String.to_integer(satoshis)
    idx = String.to_integer(vout)
    new_outputs = List.update_at(socket.assigns.tx_builder.outputs, idx, fn out ->
      %{out | subject: satoshis}
    end)


    tx_builder = %BSV.TxBuilder{
      inputs: socket.assigns.tx_builder.inputs,
      outputs: new_outputs
    }
    tx = BSV.TxBuilder.to_tx(tx_builder)

    {:noreply, assign(socket, tx_builder: tx_builder, tx: tx, outputs: new_outputs)}
  end

  def handle_event("update-opreturn", %{"value" => text, "vout" => vout}, socket) do
    idx = String.to_integer(vout)

    opreturn_data = text |> String.split(" ")
    output = socket.assigns.tx_builder.outputs |> Enum.at(idx)
    satoshis = output.subject

    new_output = OpReturn.lock(satoshis, %{data: opreturn_data})
    "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" |> Qart.debug
    new_output |> Qart.debug
    new_outputs = List.update_at(socket.assigns.tx_builder.outputs, idx, fn out ->
      new_output
    end)
    new_outputs |> Qart.debug

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

  def handle_event("add_output", _params, socket) do
    new_output = OpReturn.lock(0, %{data: [
      "hello",
      "world2"
    ]})

    updated_outputs = socket.assigns.tx_builder.outputs ++ [new_output]

    tx_builder = %BSV.TxBuilder{
      inputs: socket.assigns.tx_builder.inputs,
      outputs: updated_outputs
    }

    {:noreply, assign(socket,
      tx_builder: tx_builder,
      next_id: socket.assigns.next_id + 1
      )
    }
  end

  def handle_event("select-utxo", %{"txid" => search_txid, "vout" => vout}, socket) do
    keypair = BSV.KeyPair.new

    selected_utxo = Enum.find(socket.assigns.utxos, fn utxo ->
      txid = utxo.outpoint |> BSV.OutPoint.get_txid
      txid == search_txid
    end)

    new_input = P2PKH.unlock(selected_utxo, %{keypair: keypair})

    updated_inputs = socket.assigns.inputs ++ [new_input]

    tx_builder = %BSV.TxBuilder{
      inputs: updated_inputs,
      outputs: socket.assigns.tx_builder.outputs
    }

    {:noreply, assign(socket,
      inputs: updated_inputs,
      tx_builder: tx_builder,
      next_id: socket.assigns.next_id + 1
      )
    }
  end

  # Remove a UTXO from inputs
  def handle_event("unselect-utxo", %{"txid" => search_txid, "vout" => vout}, socket) do
    selected_utxo = Enum.find(socket.assigns.tx_builder.inputs, fn contract ->
      txid = contract.subject.outpoint |> BSV.OutPoint.get_txid
      txid == search_txid
    end)

    # The Proper thing to do here is:
    # Update socket UTXOs
    # Then populate the objects from them in a standard-ish way
    updated_inputs = Enum.reject(socket.assigns.inputs, fn contract ->
      Enum.any?(socket.assigns.inputs, fn
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
      inputs: updated_inputs,
      tx_builder: tx_builder,
      next_id: socket.assigns.next_id - 1
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

    # utxo from INPUT

    new_input = P2PKH.unlock(utxo, %{keypair: keypair})

    updated_inputs = socket.assigns.inputs ++ [new_input]

    tx_builder = %BSV.TxBuilder{
      inputs: updated_inputs,
      outputs: socket.assigns.tx_builder.outputs
    }

    {:noreply, assign(socket,
      inputs: updated_inputs,
      tx_builder: tx_builder,
      next_id: socket.assigns.next_id + 1
      )
    }
  end

  def handle_event("delete-input", %{"value" => txid, "vout" => vout}, socket) do
    keypair = BSV.KeyPair.new

    idx = String.to_integer(vout)
    # updated_inputs = socket.assigns.inputs
    updated_inputs = List.delete_at(socket.assigns.inputs, idx)

    tx_builder = %BSV.TxBuilder{
      inputs: updated_inputs,
      outputs: socket.assigns.tx_builder.outputs
    }

    {:noreply, assign(socket,
      inputs: updated_inputs,
      tx_builder: tx_builder,
      next_id: socket.assigns.next_id - 1
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
  # def handle_event("clickwrap", %{"content" => content}, socket) do
  def handle_event("clickwrap", params, socket) do
    user = socket.assigns.current_user
    user_id = socket.assigns.current_user.id
    default_wallet_id = socket.assigns.default_wallet_id
    # wallet = Qart.Accounts.get_user_active_wallet(user_id)
    wallet = Qart.Accounts.get_user_wallet(user_id, default_wallet_id)
    addresses = Qart.Accounts.get_wallet_addresses(wallet.id)
    [address | _] = addresses

    encrypted = socket.assigns.encrypted

    case WalletSession.derive_keypair(wallet.id, address.derivation_path) do
      {:ok, keypair} ->

        # final_content =
        #   if encrypted do
        #     # Crypto.encrypt(content)
        #     content
        #   else
        #     content
        #   end

        # inputs = socket.assigns.inputs
        # Create an unsigned BSV transaction that embeds the document (e.g., via an OP_RETURN output).
        socket.assigns.tx_builder.inputs |> Qart.debug
        tx_builder = %BSV.TxBuilder{
          inputs: socket.assigns.tx_builder.inputs,
          outputs: socket.assigns.tx_builder.outputs
        }

        tx = BSV.TxBuilder.to_tx(tx_builder)
        # Qart.debug(tx)
        tx_string = BSV.Tx.to_binary(tx, encoding: :hex)
        tx_string_base64 = BSV.Tx.to_binary(tx, encoding: :base64)
        Qart.debug(tx_string)

        {:noreply, assign(socket,
          tx_result: tx_string,
          tx_result_base64: tx_string_base64,
          tx_builder: tx_builder,
          wallet_id: wallet.id,
          address: address.address,
          derivation_path: address.derivation_path,
          tx: tx
        )}

      {:error, _reason} ->
        Qart.debug("~~~~~~~~~~~~~~~~~")
    end
  end

  def handle_event("sync-address", %{"address" => address}, socket) do
    {:ok, utxos} = Qart.Wallet.Sync.loop_addresses_for_utxos
    Qart.debug("sync-address")
    Qart.debug(utxos)
    {:noreply, assign(socket, wallet_last_synced_at: DateTime.utc_now())}
  end

  def handle_event("validate", _, socket) do
    keypair = BSV.KeyPair.new()
    keypair2 = BSV.KeyPair.new()
    lock_params = %{address: BSV.Address.from_pubkey(keypair.pubkey)}
    # unlock_params = %{keypair: keypair2}
    unlock_params = %{keypair: keypair}

    case BSV.Contract.simulate(P2PKH, lock_params, unlock_params) do
      {:ok, vm} ->
        valid_contract = BSV.VM.valid?(vm)
        {:noreply, assign(socket, valid_contract: valid_contract)}

      {:error, x }  ->
        Qart.debug(x)
        Qart.debug(x.error)
        {:noreply, assign(socket, valid_contract: false, contract_error: x.error)}
    end

  end

  def handle_event("validate2", _, socket) do
    keypair = BSV.KeyPair.new()
    address = Qart.Accounts.get_address_keypair(19, "mwqvASigS4AEAWGtHYcgV2xFVrADC4KaG4")
    Qart.debug(address)
    {:ok, addy} = BSV.Address.from_string(address.address)
    # {:ok, keypair2} = BSV.Address.from_string(address.address).keypair

    # UNLOCKING
    address2 = Qart.Accounts.get_address_keypair(19, "mpVjxzWwqLSgMnD2a6sfq64q24Vk2LTkBa")

    # THIS WORKS
    # {:ok, keypair2} = WalletSession.derive_keypair(19, address.derivation_path)

    # THIS FAILS
    {:ok, keypair2} = WalletSession.derive_keypair(19, address2.derivation_path)


    # NEW for testing from a real address
    lock_params = %{address: addy}
    unlock_params = %{keypair: keypair2}

    case BSV.Contract.simulate(P2PKH, lock_params, unlock_params) do
      {:ok, vm} ->
        valid_contract2 = BSV.VM.valid?(vm)
        {:noreply, assign(socket, valid_contract2: valid_contract2)}

      {:error, x }  ->
        Qart.debug(x)
        Qart.debug(x.error)
        {:noreply, assign(socket, valid_contract2: false, contract_validation_error: x.error, contract_error: x.error)}
    end

  end

  @impl true
  def handle_event("open_modal", %{"id" => id}, socket) do
    tx = Enum.find(socket.assigns.transactions, fn tx -> to_string(tx.id) == id end)
    # Qart.debug(id)
    # Qart.debug(socket.assigns.transactions |> Enum.at(0))
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
        "height" => height,
        "isSpentInMempoolTx" => isSpentInMempoolTx,
        "status" => status,
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
    utxos
  end










end
