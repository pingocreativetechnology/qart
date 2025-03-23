defmodule QartWeb.WalletLive.Index do
  use QartWeb, :live_view
  alias Qart.Wallet.WalletSession
  alias Qart.Accounts

  def mount(_params, session, socket) do
    user_id = socket.assigns.current_user.id
    wallet = []
    wallets = Accounts.get_user_wallets(user_id)

    socket =
      socket
      |> assign(mnemonic: nil)
      |> assign(derivation_path: nil)
      |> assign(address_string: nil)
      |> assign(wallet: wallet)
      |> assign(wallets: wallets)
      # |> assign(current_derivation: wallet.current_derivation)
      |> assign(current_derivation: nil)

    {:ok, assign(socket, mnemonic_shown: false, user_id: user_id, addresses: [])}
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

  def handle_event("reveal_mnemonic", _params, socket) do
    {:noreply, assign(socket, mnemonic_shown: true)}
  end

  def handle_event("clear_wallet", _params, socket) do
    WalletSession.clear_wallet()
    {:noreply, assign(socket, wallet: nil)}
  end

end
