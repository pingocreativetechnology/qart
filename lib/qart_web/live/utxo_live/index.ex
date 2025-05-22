defmodule QartWeb.UtxoLive.Index do
  use QartWeb, :live_view

  alias Qart.Transactions
  alias Qart.Transactions.Utxo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :utxos, Transactions.list_utxos_by_user(socket.assigns.current_user.id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Utxo")
    |> assign(:utxo, Transactions.get_utxo!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Utxo")
    |> assign(:utxo, %Utxo{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Utxos")
    |> assign(:utxo, nil)
  end

  @impl true
  def handle_info({QartWeb.UtxoLive.FormComponent, {:saved, utxo}}, socket) do
    {:noreply, stream_insert(socket, :utxos, utxo)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    utxo = Transactions.get_utxo!(id)
    {:ok, _} = Transactions.delete_utxo(utxo)

    {:noreply, stream_delete(socket, :utxos, utxo)}
  end
end
