defmodule QartWeb.TransactionLiveTest do
  use QartWeb.ConnCase

  import Phoenix.LiveViewTest
  import Qart.TransactionsFixtures
  import Qart.UserFixtures

  @create_attrs %{
    raw: "AQAAAAFYjpS29sCiqSWw2Acrf7a0qucKdIfwAklchldIAy19pUgAAABqRzBEAiBScc0e0aWrxEttmxF1swzCQMgU8u9k2QP09nPeS8hPLQIgBqEQR9gDPayOsz9EBy6XFK6T5dzPbg5Kfcy1o0PQ6/tBIQKSrNtXx4jB6Mg82wro8j4HkTm6e6G8z2ezFlPHrxLEtP////8BQIYBAAAAAAAZdqkUUoN1xA79dzu8IbgUZTa3PCKaCgaIrAAAAAA=",
    version: "some version",
    txid: "3a34b6c5e49cfa9841631cf6aa7120d044c0916f1a7f2d1bb0d95841df54b700",
    block_hash: "some block_hash", spent: true, notes: "some notes"}
  @update_attrs %{
    raw: "AQAAAAFYjpS29sCiqSWw2Acrf7a0qucKdIfwAklchldIAy19pUgAAABqRzBEAiBScc0e0aWrxEttmxF1swzCQMgU8u9k2QP09nPeS8hPLQIgBqEQR9gDPayOsz9EBy6XFK6T5dzPbg5Kfcy1o0PQ6/tBIQKSrNtXx4jB6Mg82wro8j4HkTm6e6G8z2ezFlPHrxLEtP////8BQIYBAAAAAAAZdqkUUoN1xA79dzu8IbgUZTa3PCKaCgaIrAAAAAA=",
    version: "some updated version", txid: "3a34b6c5e49cfa9841631cf6aa7120d044c0916f1a7f2d1bb0d95841df54b700",
    block_hash: "some updated block_hash", spent: false, notes: "some updated notes"}
  @invalid_attrs %{raw: nil, version: nil, txid: nil, block_hash: nil, merkle_proof: nil, spent: false, notes: nil}

  defp create_transaction(_) do
    transaction = transaction_fixture()
    %{transaction: transaction}
  end

  defp log_user_in(_) do
    user = user_fixture()
    conn = build_conn() |> log_in_user(user)
    %{conn: conn, user: user}
  end

  describe "Index" do
    setup [:create_transaction, :log_user_in]

    test "lists all transactions", %{conn: conn, transaction: transaction} do
      {:ok, _index_live, html} = live(conn, ~p"/transactions")

      assert html =~ "Listing Transactions"
      assert html =~ transaction.raw |> String.slice(0, 100)
    end

    test "saves new transaction", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/transactions")

      assert index_live |> element("a", "New Transaction")
        |> render_click() =~ "New Transaction"

      assert_patch(index_live, ~p"/transactions/new")

      assert index_live
             |> form("#transaction-form", transaction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#transaction-form", transaction: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/transactions")

      html = render(index_live)
      assert html =~ "Transaction created successfully"
      assert html =~ "AQAAAAFYjpS29sCiqSWw2Acrf7a0qucKdIfwAkl"
    end

    test "updates transaction in listing", %{conn: conn, transaction: transaction} do
      {:ok, index_live, _html} = live(conn, ~p"/transactions")

      assert index_live |> element("#transactions-#{transaction.id} a", "Edit")
        |> render_click() =~ "Edit Transaction"

      assert_patch(index_live, ~p"/transactions/#{transaction}/edit")

      assert index_live
             |> form("#transaction-form", transaction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#transaction-form", transaction: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/transactions")

      html = render(index_live)
      assert html =~ "Transaction updated successfully"
      assert html =~ "AQAAAAFYjpS29sCiqSWw2Acrf7a0qucKdIfwAklchldIAy19pUgAAAB"
    end

    test "deletes transaction in listing", %{conn: conn, transaction: transaction} do
      {:ok, index_live, _html} = live(conn, ~p"/transactions")

      assert index_live |> element("#transactions-#{transaction.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#transactions-#{transaction.id}")
    end
  end

  describe "Show" do
    setup [:create_transaction, :log_user_in]

    test "displays transaction", %{conn: conn, transaction: transaction} do
      {:ok, _show_live, html} = live(conn, ~p"/transactions/#{transaction}")

      assert html =~ "Show Transaction"
      assert html =~ transaction.raw
    end

    test "updates transaction within modal", %{conn: conn, transaction: transaction} do
      {:ok, show_live, _html} = live(conn, ~p"/transactions/#{transaction}")

      assert show_live
        |> element("a", "Edit")
        |> render_click() =~ "Edit Transaction"

      assert_patch(show_live, ~p"/transactions/#{transaction}/show/edit")

      assert show_live
             |> form("#transaction-form", transaction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#transaction-form", transaction: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/transactions/#{transaction}")

      html = render(show_live)
      assert html =~ "Transaction updated successfully"
      assert html =~ "AQAAAAFYjpS29sCiqSWw2Acrf7a0qucKdIfwAklchldIAy19pUgAAABqRzBEAiBScc0e0aWrxEttmxF1swzCQMgU8u9k2QP09nPeS8hPLQIgBqEQR9gDPayOsz9EBy6XFK6T5dzPbg5Kfcy1o0PQ6/tBIQKSrNtXx4jB6Mg82wro8j4HkTm6e6G8z2ezFlPHrxLEtP////8BQIYBAAAAAAAZdqkUUoN1xA79dzu8IbgUZTa3PCKaCgaIrAAAAAA="
    end
  end
end
