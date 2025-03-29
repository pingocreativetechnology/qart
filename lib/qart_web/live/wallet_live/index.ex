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
      |> assign(words: nil)
      |> assign(wallets: wallets)
      |> assign(show_restore_wallet_form: false)
      # |> assign(current_derivation: wallet.current_derivation)
      |> assign(current_derivation: nil)

    {:ok, assign(socket, mnemonic_shown: false, user_id: user_id, addresses: [])}
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
        {:noreply, assign(socket, wallet: wallet, mnemonic: mnemonic)}

      {:ok, wallet} ->
        {:noreply, assign(socket, wallet: wallet)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to generate wallet")}
    end
  end

  ### NEW WALLET STUFF
  @impl true
  def handle_event("generate_wallet", _params, socket) do

    case WalletSession.generate_wallet(socket.assigns.user_id) do
      {:ok, wallet, mnemonic} ->
        socket = socket |> put_flash(:info, "Wallet generated successfully")
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
