defmodule QartWeb.UtxoLiveTest do
  use QartWeb.ConnCase

  import Phoenix.LiveViewTest
  import Qart.TransactionsFixtures
  import Qart.AccountsFixtures
  alias QartWeb.UserAuth

  @create_attrs %{script: "76a914b3182303bb218b771cc7cbf84d9ddacfbd6180b088ac", txid: "4f349749c5e86aa95a92341d6f3c0138aa8359d47c278a1d1195c34baba7144e", vout: 42, satoshis: 42, spent: true, spent_at: "2025-04-18T21:13:00Z"}
  @update_attrs %{script: "76a914c565e265052ccec4d1dd7bed4600c7e82a28cb3388ac", txid: "9f797ad1ca0a8796a2f3464565d3cb34835725c81bc01ed3d9bfea67f733a4ab", vout: 43, satoshis: 43, spent: false, spent_at: "2025-04-19T21:13:00Z"}
  @invalid_attrs %{script: nil, txid: nil, vout: nil, satoshis: nil, spent: false, spent_at: nil}

  defp create_utxo_and_login(_) do
    user = user_fixture()
    utxo = utxo_fixture(%{user_id: user.id})
    conn = build_conn() |> log_in_user(user)
    %{conn: conn, user: user, utxo: utxo}
  end

  describe "Index" do
    setup [:create_utxo_and_login]

    test "lists all utxos", %{conn: conn, utxo: utxo} do
      {:ok, _index_live, html} = live(conn, ~p"/utxos")

      assert html =~ "Listing Utxos"
      assert html =~ "Txid"
      assert html =~ "Vout"
      assert html =~ "Satoshis"
      assert html =~ "Spent"
      assert html =~ utxo.txid
    end

    test "saves new utxo", %{conn: conn, user: user} do
      conn = build_conn() |> log_in_user(user)

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
      assert html =~ "4f349749c5e86aa95a92341d6f3c0138aa8359d47c278a1d1195c34baba7144e"
    end

    test "updates utxo in listing", %{conn: conn, utxo: utxo, user: user} do
      conn = build_conn() |> log_in_user(user)

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

      assert html =~ "9f797ad1ca0a8796a2f3464565d3cb34835725c81bc01ed3d9bfea67f733a4ab"
    end

    test "deletes utxo in listing", %{conn: conn, utxo: utxo} do
      {:ok, index_live, _html} = live(conn, ~p"/utxos")

      assert index_live |> element("#utxos-#{utxo.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#utxos-#{utxo.id}")
    end
  end

  describe "Show" do
    setup [:create_utxo_and_login]

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
      assert html =~ "9f797ad1ca0a8796a2f3464565d3cb34835725c81bc01ed3d9bfea67f733a4ab"
    end
  end
end
