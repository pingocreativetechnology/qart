defmodule QartWeb.ItemLive.Index do
  use QartWeb, :live_view

  alias Qart.Inventory
  alias Qart.Inventory.Item

  @impl true
  def mount(params, _session, socket) do

    view_template =
      case socket.assigns[:live_action] do
        :grid -> "grid"
        :table -> "table"
        _ -> "grid"
      end

    case params do
      %{"tag" => tag_name} ->
        items = Inventory.list_items_by_tag(tag_name)
        {:ok, stream(socket, :items, items, view_template: view_template)}

      _ ->
        items = Inventory.list_items()
        {:ok, stream(socket, :items, items, view_template: view_template)}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Item")
    |> assign(:item, Inventory.get_item!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Item")
    |> assign(:item, %Item{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Items")
    |> assign(:item, nil)
  end

  defp apply_action(socket, :list, _params) do
    socket
    |> assign(:page_title, "Listing Items")
    |> assign(:item, nil)
  end

  @impl true
  def handle_info({QartWeb.ItemLive.FormComponent, {:saved, item}}, socket) do
    {:noreply, stream_insert(socket, :items, item)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    item = Inventory.get_item!(id)
    {:ok, _} = Inventory.delete_item(item)

    {:noreply, stream_delete(socket, :items, item)}
  end
end
