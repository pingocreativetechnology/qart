defmodule Qart.Wallet.WalletSession do
  use GenServer
  alias Qart.Repo
  alias Qart.Wallet.{Wallet, Address}

  ## API
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def generate_wallet(user_id) do
    GenServer.call(__MODULE__, {:generate_wallet, user_id})
  end

  def get_wallet() do
    GenServer.call(__MODULE__, :get_wallet)
  end

  def derive_new_address(wallet_id) do
    GenServer.call(__MODULE__, {:derive_new_address, wallet_id})
  end

  def clear_wallet() do
    GenServer.cast(__MODULE__, :clear_wallet)
  end

  ## GenServer Callbacks
  @spec init(any()) :: {:ok, %{mnemonic: nil, seed: nil}}
  def init(_) do
    {:ok, %{mnemonic: nil, seed: nil}}
  end

  def handle_call({:find_or_create_wallet, user_id}, _from, _state) do
    wallet = Repo.get_by(Wallet, user_id: user_id)

    case wallet do
      %Qart.Wallet.Wallet{} ->
        IO.puts "found a wallet #{wallet.id}"
        {:reply, {:ok, wallet}, wallet}

      _ ->
        # TODO: SEND A CALL TO `generate_wallet` WALLET HERE INSTEAD
        IO.puts "creating a wallet"

        mnemonic = BSV.Mnemonic.new()
        seed = BSV.Mnemonic.to_seed(mnemonic)
        extkey = BSV.ExtKey.from_seed!(seed)
        wallet = %Wallet{user_id: user_id, seed: seed, current_derivation: 0}
        {:ok, saved_wallet} = Repo.insert(wallet)

        {:reply, {:ok, saved_wallet, mnemonic}, saved_wallet}
    end
  end

  def handle_call({:generate_wallet, user_id}, _from, _state) do
      mnemonic = BSV.Mnemonic.new()
      seed = BSV.Mnemonic.to_seed(mnemonic)
      extkey = BSV.ExtKey.from_seed!(seed)
      wallet = %Wallet{user_id: user_id, seed: seed, current_derivation: 0}
      {:ok, saved_wallet} = Repo.insert(wallet)

      {:reply, {:ok, saved_wallet, mnemonic}, saved_wallet}
  end

  def handle_call({:derive_new_address, wallet_id}, _from, state) do
    wallet = Repo.get_by(Wallet, id: wallet_id)

    if wallet do
      new_derivation = wallet.current_derivation + 1
      derivation_path = "m/44'/0'/0'/0/#{new_derivation}"

      # Generate address from seed and derivation path
      {:ok, address_string} = generate_bitcoin_address(wallet.seed, derivation_path)

      new_address = %Address{
        wallet_id: wallet.id,
        address: address_string,
        derivation_path: derivation_path
      }

      Repo.transaction(fn ->
        Repo.insert!(new_address)
        Repo.update!(Ecto.Changeset.change(wallet, current_derivation: new_derivation))
      end)

      {:reply, {:ok, new_address}, wallet}
    else
      {:reply, {:error, "Wallet not found"}, state}
    end
  end

  defp generate_bitcoin_address(seed, derivation_path) do
    extkey = BSV.ExtKey.from_seed!(seed)
    child = BSV.ExtKey.derive(extkey, derivation_path)
    address = BSV.Address.from_pubkey(child.pubkey)
    address_string = BSV.Address.to_string(address)
    {:ok, address_string}
  end

  # def handle_call(:get_wallet, _from, state) do
  #   if state.mnemonic do
  #     {:reply, {:ok, state}, state}
  #   else
  #     {:reply, {:error, "No wallet found"}, state}
  #   end
  # end

  # def handle_cast(:clear_wallet, _state) do
  #   {:noreply, %{mnemonic: nil, seed: nil}}
  # end
end
