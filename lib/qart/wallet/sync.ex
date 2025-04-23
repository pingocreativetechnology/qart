defmodule Qart.Wallet.Sync do

  # Syncs a whole set of Addresses
  # typically, in a Wallet
  def loop_addresses_for_utxos do
    Qart.debug("loop_addresses_for_utxos")

    addresses = [
      "mwqvASigS4AEAWGtHYcgV2xFVrADC4KaG4",
    ]

    [utxos] = Enum.map(addresses, fn address ->
      {:ok, utxos} = address_utxos(address)
      utxos
    end)

    {:ok, utxos}
  end

  def address_utxos(address) do
    {:ok, %{"result" => utxos}} = Qart.WhatsOnChain.get_address_utxos(address)
    {:ok, utxos}
  end

end
