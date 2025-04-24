defmodule QartWeb.UtxoLiveTest do
  use QartWeb.ConnCase

  import Phoenix.LiveViewTest
  import Qart.TransactionsFixtures

  @create_attrs %{script: "some script", txid: "some txid", vout: 42, satoshis: 42, spent: true, spent_at: "2025-04-18T21:13:00Z"}
  @update_attrs %{script: "some updated script", txid: "some updated txid", vout: 43, satoshis: 43, spent: false, spent_at: "2025-04-19T21:13:00Z"}
  @invalid_attrs %{script: nil, txid: nil, vout: nil, satoshis: nil, spent: false, spent_at: nil}

  defp create_utxo(_) do
    utxo = utxo_fixture()
    %{utxo: utxo}
  end

  describe "Index" do
    setup [:create_utxo]

    test "lists all utxos", %{conn: conn, utxo: utxo} do
      {:ok, _index_live, html} = live(conn, ~p"/utxos")

      assert html =~ "Listing Utxos"
      assert html =~ utxo.script
    end

    test "saves new utxo", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/utxos")

      assert index_live |> element("a", "New Utxo") |> render_click() =~
               "New Utxo"

      assert_patch(index_live, ~p"/utxos/new")

      assert index_live
             |> form("#utxo-form", utxo: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#utxo-form", utxo: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/utxos")

      html = render(index_live)
      assert html =~ "Utxo created successfully"
      assert html =~ "some script"
    end

    test "updates utxo in listing", %{conn: conn, utxo: utxo} do
      {:ok, index_live, _html} = live(conn, ~p"/utxos")

      assert index_live |> element("#utxos-#{utxo.id} a", "Edit") |> render_click() =~
               "Edit Utxo"

      assert_patch(index_live, ~p"/utxos/#{utxo}/edit")

      assert index_live
             |> form("#utxo-form", utxo: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#utxo-form", utxo: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/utxos")

      html = render(index_live)
      assert html =~ "Utxo updated successfully"
      assert html =~ "some updated script"
    end

    test "deletes utxo in listing", %{conn: conn, utxo: utxo} do
      {:ok, index_live, _html} = live(conn, ~p"/utxos")

      assert index_live |> element("#utxos-#{utxo.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#utxos-#{utxo.id}")
    end
  end

  describe "Show" do
    setup [:create_utxo]

    test "displays utxo", %{conn: conn, utxo: utxo} do
      {:ok, _show_live, html} = live(conn, ~p"/utxos/#{utxo}")

      assert html =~ "Show Utxo"
      assert html =~ utxo.script
    end

    test "updates utxo within modal", %{conn: conn, utxo: utxo} do
      {:ok, show_live, _html} = live(conn, ~p"/utxos/#{utxo}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Utxo"

      assert_patch(show_live, ~p"/utxos/#{utxo}/show/edit")

      assert show_live
             |> form("#utxo-form", utxo: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#utxo-form", utxo: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/utxos/#{utxo}")

      html = render(show_live)
      assert html =~ "Utxo updated successfully"
      assert html =~ "some updated script"
    end
  end
end
