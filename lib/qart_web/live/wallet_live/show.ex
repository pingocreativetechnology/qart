defmodule QartWeb.WalletLive.Show do
  use QartWeb, :live_view
  alias Qart.Wallet.WalletSession
  alias Qart.Accounts

  def mount(_params, session, socket) do
    user_id = socket.assigns.current_user.id
    wallet = nil

    socket =
      socket
      |> assign(user_id: user_id)
      |> assign(wallet: wallet)
      |> assign(mnemonic: nil)
      |> assign(derivation_path: nil)
      |> assign(address_string: nil)
      |> assign(current_derivation: nil)
      |> assign(addresses: [])

    {:ok, socket}
  end

  # used for Active Wallet - /wallet
  @impl true
  def handle_params(params, _uri, socket) do
    user_id = socket.assigns.current_user.id
    wallet = Accounts.get_user_active_wallet(user_id)
    {:noreply, assign(socket, wallet: wallet)}
  end

  # used for any Wallet - /wallets/:id
  def handle_params(%{"id" => wallet_id}, _uri, socket) do
    user_id = socket.assigns.current_user.id
    wallet = Accounts.get_user_wallet(user_id, wallet_id)
    # wallet = Accounts.get_user_wallet(user_id, wallet_id)
    user_id = socket.assigns.current_user.id
    {:noreply, assign(socket, wallet: wallet)}
  end

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


  ### NEW WALLET STUFF
  @impl true
  def handle_event("generate_wallet", _params, socket) do

    case WalletSession.generate_wallet(socket.assigns.user_id) do
      {:ok, wallet, mnemonic} ->
        {:noreply, assign(socket, wallet: wallet, mnemonic: mnemonic)}

      {:ok, wallet} ->
        {:noreply, assign(socket, wallet: wallet)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to generate wallet")}
    end
  end

  def handle_event("derive_address", _params, socket) do
    # case WalletSession.derive_new_address(socket.assigns.user_id) do
    case WalletSession.derive_new_address(socket.assigns.wallet.id) do
      {:ok, new_address} ->
        updated_addresses = [new_address | socket.assigns.addresses]
        wallet = socket.assigns.wallet
        {:noreply, assign(socket, addresses: updated_addresses, wallet: wallet, current_derivation: wallet.current_derivation)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to derive address")}
    end
  end

  def handle_event("load_addresses", _params, socket) do
    addresses = Accounts.get_wallet_addresses(socket.assigns.wallet.id)
    {:noreply, assign(socket, addresses: addresses)}
  end

  def handle_event("clear_wallet", _params, socket) do
    WalletSession.clear_wallet()
    {:noreply, assign(socket, wallet: nil)}
  end

end
