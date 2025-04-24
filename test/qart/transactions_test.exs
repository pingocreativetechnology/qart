defmodule Qart.TransactionsTest do
  use Qart.DataCase

  alias Qart.Transactions

  describe "transactions" do
    alias Qart.Transactions.Transaction

    import Qart.TransactionsFixtures

    @invalid_attrs %{raw: nil, version: nil, inputs: [], txid: nil, block_hash: nil, outputs: [], merkle_proof: nil, spent: nil, addresses: [], notes: nil}

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert Transactions.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Transactions.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      valid_attrs = %{raw: "some raw", version: "some version", inputs: ["some inputs"], txid: "some txid", block_hash: "some block_hash", outputs: ["some outputs"], merkle_proof: ["some merkle_proof"], spent: true, addresses: ["some addresses"], notes: "some notes"}

      assert {:ok, %Transaction{} = transaction} = Transactions.create_transaction(valid_attrs)
      assert transaction.raw == "some raw"
      assert transaction.version == "some version"
      assert transaction.inputs == ["some inputs"]
      assert transaction.txid == "some txid"
      assert transaction.block_hash == "some block_hash"
      assert transaction.outputs == ["some outputs"]
      assert transaction.merkle_proof == ["some merkle_proof"]
      assert transaction.spent == true
      assert transaction.addresses == ["some addresses"]
      assert transaction.notes == "some notes"
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()
      update_attrs = %{raw: "some updated raw", version: "some updated version", inputs: ["some updated inputs"], txid: "some updated txid", block_hash: "some updated block_hash",
        outputs: ["some updated outputs"],
        merkle_proof: ["some updated merkle_proof"],
        spent: false,
        addresses: ["some updated addresses"], notes: "some updated notes"}

      assert {:ok, %Transaction{} = transaction} = Transactions.update_transaction(transaction, update_attrs)
      assert transaction.raw == "some updated raw"
      assert transaction.version == "some updated version"
      assert transaction.inputs == ["some updated inputs"]
      assert transaction.txid == "some updated txid"
      assert transaction.block_hash == "some updated block_hash"
      assert transaction.outputs == ["some updated outputs"]
      assert transaction.merkle_proof == ["some updated merkle_proof"]
      assert transaction.spent == false
      assert transaction.addresses == ["some updated addresses"]
      assert transaction.notes == "some updated notes"
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()
      assert {:error, %Ecto.Changeset{}} = Transactions.update_transaction(transaction, @invalid_attrs)
      assert transaction == Transactions.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = Transactions.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Transactions.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = transaction_fixture()
      assert %Ecto.Changeset{} = Transactions.change_transaction(transaction)
    end
  end

  describe "utxos" do
    alias Qart.Transactions.Utxo

    import Qart.TransactionsFixtures

    @invalid_attrs %{script: nil, txid: nil, vout: nil, satoshis: nil, spent: nil, spent_at: nil}

    test "list_utxos/0 returns all utxos" do
      utxo = utxo_fixture()
      assert Transactions.list_utxos() == [utxo]
    end

    test "get_utxo!/1 returns the utxo with given id" do
      utxo = utxo_fixture()
      assert Transactions.get_utxo!(utxo.id) == utxo
    end

    test "create_utxo/1 with valid data creates a utxo" do
      valid_attrs = %{script: "some script", txid: "some txid", vout: 42, satoshis: 42, spent: true, spent_at: ~U[2025-04-18 21:13:00Z]}

      assert {:ok, %Utxo{} = utxo} = Transactions.create_utxo(valid_attrs)
      assert utxo.script == "some script"
      assert utxo.txid == "some txid"
      assert utxo.vout == 42
      assert utxo.satoshis == 42
      assert utxo.spent == true
      assert utxo.spent_at == ~U[2025-04-18 21:13:00Z]
    end

    test "create_utxo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_utxo(@invalid_attrs)
    end

    test "update_utxo/2 with valid data updates the utxo" do
      utxo = utxo_fixture()
      update_attrs = %{script: "some updated script", txid: "some updated txid", vout: 43, satoshis: 43, spent: false, spent_at: ~U[2025-04-19 21:13:00Z]}

      assert {:ok, %Utxo{} = utxo} = Transactions.update_utxo(utxo, update_attrs)
      assert utxo.script == "some updated script"
      assert utxo.txid == "some updated txid"
      assert utxo.vout == 43
      assert utxo.satoshis == 43
      assert utxo.spent == false
      assert utxo.spent_at == ~U[2025-04-19 21:13:00Z]
    end

    test "update_utxo/2 with invalid data returns error changeset" do
      utxo = utxo_fixture()
      assert {:error, %Ecto.Changeset{}} = Transactions.update_utxo(utxo, @invalid_attrs)
      assert utxo == Transactions.get_utxo!(utxo.id)
    end

    test "delete_utxo/1 deletes the utxo" do
      utxo = utxo_fixture()
      assert {:ok, %Utxo{}} = Transactions.delete_utxo(utxo)
      assert_raise Ecto.NoResultsError, fn -> Transactions.get_utxo!(utxo.id) end
    end

    test "change_utxo/1 returns a utxo changeset" do
      utxo = utxo_fixture()
      assert %Ecto.Changeset{} = Transactions.change_utxo(utxo)
    end
  end
end
