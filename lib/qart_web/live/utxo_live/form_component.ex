defmodule QartWeb.UtxoLive.FormComponent do
  use QartWeb, :live_component

  alias Qart.Transactions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage utxo records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="utxo-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:txid]} type="text" label="Txid" />
        <.input field={@form[:vout]} type="number" label="Vout" />
        <.input field={@form[:satoshis]} type="number" label="Satoshis" />
        <.input field={@form[:script]} type="text" label="Script" />
        <.input field={@form[:spent]} type="checkbox" label="Spent" />
        <.input field={@form[:address]} type="text" label="Address" />
        <.input field={@form[:spent_at]} type="datetime-local" label="Spent at" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Utxo</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{utxo: utxo} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Transactions.change_utxo(utxo))
     end)}
  end

  @impl true
  def handle_event("validate", %{"utxo" => utxo_params}, socket) do
    changeset = Transactions.change_utxo(socket.assigns.utxo, utxo_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"utxo" => utxo_params}, socket) do
    save_utxo(socket, socket.assigns.action, utxo_params)
  end

  defp save_utxo(socket, :edit, utxo_params) do
    case Transactions.update_utxo(socket.assigns.utxo, utxo_params) do
      {:ok, utxo} ->
        notify_parent({:saved, utxo})

        {:noreply,
         socket
         |> put_flash(:info, "Utxo updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_utxo(socket, :new, utxo_params) do
    case Transactions.create_utxo(utxo_params) do
      {:ok, utxo} ->
        notify_parent({:saved, utxo})

        {:noreply,
         socket
         |> put_flash(:info, "Utxo created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
