defmodule QartWeb.WalletUtilsComponent do
  use Phoenix.LiveComponent

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket,
      json: assigns.json,
      mnemonic: assigns.mnemonic
    )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div
      class="max-w-4xl mx-auto">
      <div
        class="text-6xl text-slate-800 font-semibold">
        Wallet Utilities
      </div>
      <form
        class="mt-8"
        phx-submit="get-txid">
        <input rows="2"
          type="text"
          name="txid"
          value="3a34b6c5e49cfa9841631cf6aa7120d044c0916f1a7f2d1bb0d95841df54b700"
          class="block w-full resize-none bg-transparent px-3 py-1.5 text-base text-slate-800 placeholder:text-gray-400 focus:outline focus:outline-0 sm:text-sm/6"
          placeholder="Add your comment..." />
        <button
          type="submit"
          class="my-2 inline-flex justify-center rounded-md px-3 py-2 text-sm font-semibold shadow-sm ring-1 ring-inset text-slate-800 bg-green-50  hover:bg-gray-50 ring-gray-300">
          Download TXID from WhatsOnChain
        </button>
      </form>

      <form
        class="mt-8"
        phx-submit="get-utxos">
        <input rows="2"
          type="text"
          name="address"
          value="mpVjxzWwqLSgMnD2a6sfq64q24Vk2LTkBa"
          class="block w-full resize-none bg-transparent px-3 py-1.5 text-base text-slate-800 placeholder:text-gray-400 focus:outline focus:outline-0 sm:text-sm/6"
          placeholder="Add your comment..." />
        <button
          type="submit"
          class="my-2 inline-flex justify-center rounded-md px-3 py-2 text-sm font-semibold shadow-sm ring-1 ring-inset text-slate-800 bg-green-50  hover:bg-gray-50 ring-gray-300">
          Download UTXOs for an Address from WhatsOnChain
        </button>
      </form>

      <div
        class="font-mono"
        style="word-break: break-all;">
        {@json |> inspect}
      </div>

      <div
        name="generate-mnemonic"
        class="mt-24">
        <button type="button" phx-click="generate_mnemonic" class={"my-2 inline-flex justify-center rounded-md px-3 py-2 text-sm
          font-semibold shadow-sm ring-1 ring-inset text-gray-900 " <>
                    " bg-blue-100 hover:bg-blue-200 ring-blue-200"}>
          <svg class="-ml-0.5 mr-1.5 size-5 text-slate-800" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
            stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round"
              d="M15.042 21.672 13.684 16.6m0 0-2.51 2.225.569-9.47 5.227 7.917-3.286-.672ZM12 2.25V4.5m5.834.166-1.591 1.591M20.25 10.5H18M7.757 14.743l-1.59 1.59M6 10.5H3.75m4.007-4.243-1.59-1.59" />
          </svg>
          <span>Generate Mnemonic</span>
        </button>
        <p class="text-xs mt-1 text-gray-600">
          This is a one-off function.
          The mnemonic is not saved: store the 12 words yourself if want to re-use it.
        </p>

        <div
          class="font-mono">
          <%= @mnemonic %>
        </div>
      </div>
    </div>
    """
  end
end
