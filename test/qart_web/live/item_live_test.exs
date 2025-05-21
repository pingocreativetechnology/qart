defmodule QartWeb.ItemLiveTest do
  use QartWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Qart.InventoryFixtures
  import Qart.AccountsFixtures

  def create_attrs() do
   %{name: "some name", description: "some description", price: "120.5", tags: %{}}
  end

  # def create_attrs(user_id) do
  #  %{name: "some name", description: "some description", price: "120.5", tags: %{}, user_id: user_id}
  # end

  @update_attrs %{name: "some updated name", status: "some updated status", description: "some updated description", price: "456.7", tags: %{}}
  @invalid_attrs %{name: nil, description: nil, tags: nil}

  defp create_item(_) do
    item = item_fixture()
    %{item: item}
  end

  defp log_user_in(_) do
    user = user_fixture()
    user_item = item_fixture(%{user_id: user.id})
    conn = build_conn() |> log_in_user(user)
    %{conn: conn, user: user, user_item: user_item}
  end

  describe "Index" do
    setup [:create_item, :log_user_in]

    test "lists a user's items", %{conn: conn, user_item: user_item} do
      {:ok, _index_live, html} = live(conn, ~p"/items")

      assert html =~ "Items"
      assert html =~ user_item.name
      assert html =~ "Edit"
      assert html =~ "Delete"
    end

    test "saves new item", %{conn: conn, user: user} do
      {:ok, index_live, _html} = live(conn, ~p"/items")

      assert index_live
        |> element("a", "New Item")
        |> render_click() =~ "New Item"

      assert_patch(index_live, ~p"/items/new")

      assert index_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#item-form", item: create_attrs())
             |> render_submit()

      assert_patch(index_live, ~p"/items")

      html = render(index_live)
      assert html =~ "Item created successfully"
      assert html =~ "some name"
    end

    test "updates item in listing", %{conn: conn, user_item: user_item} do
      {:ok, index_live, _html} = live(conn, ~p"/items")

      assert index_live
        |> element("#items-#{user_item.id} a", "Edit")
        |> render_click() =~ "Save Item"

      assert_patch(index_live, ~p"/items/#{user_item}/edit")

      assert index_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#item-form", item: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/items")

      html = render(index_live)
      assert html =~ "Item updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes item in listing", %{conn: conn, user_item: user_item} do
      {:ok, index_live, _html} = live(conn, ~p"/items")

      assert index_live |> element("#items-#{user_item.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#items-#{user_item.id}")
    end
  end

  describe "Show" do
    setup [:create_item, :log_user_in]

    test "displays item", %{conn: conn, item: item} do
      {:ok, _show_live, html} = live(conn, ~p"/items/#{item}")

      assert html =~ "Show Item"
      assert html =~ item.name
    end

    test "updates item within modal", %{conn: conn, item: item} do
      {:ok, show_live, _html} = live(conn, ~p"/items/#{item}")

      assert show_live
        |> element("a", "Edit")
        |> render_click() =~ "Edit Item"

      assert_patch(show_live, ~p"/items/#{item}/show/edit")

      assert show_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#item-form", item: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/items/#{item}")

      html = render(show_live)
      assert html =~ "Item updated successfully"
      assert html =~ "some updated name"
    end
  end
end
