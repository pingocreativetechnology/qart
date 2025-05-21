defmodule QartWeb.ItemLive.Catalog do
  use QartWeb, :live_view

  alias Qart.Inventory
  alias Qart.Inventory.Item

  @impl true

  # def catalog(conn, _params) do
  #   items = case conn.assigns.current_user do
  #     nil ->
  #       Qart.Inventory.list_items()

  #     x ->
  #       Qart.Inventory.list_items()
  #       |> Enum.reject(&(&1.user_id == conn.assigns.current_user.id))
  #   end

  #   render(conn, :catalog,
  #     page_title: "Catalog",
  #     filters: %{},
  #     items: items
  #   )
  # end

  def mount(params, _session, socket) do

    view_template =
      case socket.assigns[:live_action] do
        :grid -> "grid"
        :table -> "table"
        _ -> "grid"
      end

    # case params do
    #   %{"tag" => tag_name} ->
    #     items = Inventory.list_items_by_tag(tag_name)
    #     {:ok, stream(socket, :items, items, view_template: view_template)}

    #   _ ->
    #     items = Inventory.list_items(socket.assigns.current_user)
    #     {:ok, stream(socket, :items, items, view_template: view_template)}
    # end

    # items = Inventory.list_items(socket.assigns.current_user)
    items = Inventory.list_items()
    # {:ok, stream(socket, :items, items)}
    {:ok, assign(socket, items: items)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("search", %{"q" => _} = filters, socket) do
    items = Inventory.list_items(filters)
    # items = socket.assigns.items

    {:noreply,
    socket
    |> assign(:items, items)
    |> assign(:filters, filters)}
  end

  defp apply_action(socket, :catalog, _params) do
    socket
    |> assign(:page_title, "Listing Items")
    |> assign(:item, nil)
    |> assign(:filters, %{})
  end

  @impl true
  def handle_info({QartWeb.ItemLive.FormComponent, {:saved, item}}, socket) do
    {:noreply, stream_insert(socket, :items, item)}
  end
end
