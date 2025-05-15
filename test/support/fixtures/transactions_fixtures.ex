defmodule Qart.TransactionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Qart.Transactions` context.
  """

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        addresses: ["some addresses"],
        block_hash: "some block_hash",
        merkle_proof: ["some merkle_proof"],
        notes: "some notes",
        inputs: ["some inputs"],
        outputs: ["some outputs"],
        raw: "AQAAAAFYjpS29sCiqSWw2Acrf7a0qucKdIfwAklchldIAy19pUgAAABqRzBEAiBScc0e0aWrxEttmxF1swzCQMgU8u9k2QP09nPeS8hPLQIgBqEQR9gDPayOsz9EBy6XFK6T5dzPbg5Kfcy1o0PQ6/tBIQKSrNtXx4jB6Mg82wro8j4HkTm6e6G8z2ezFlPHrxLEtP////8BQIYBAAAAAAAZdqkUUoN1xA79dzu8IbgUZTa3PCKaCgaIrAAAAAA=",
        spent: true,
        txid: "some txid",
        version: "some version"
      })
      |> Qart.Transactions.create_transaction()

    transaction
  end

  @doc """
  Generate a utxo.
  """
  def utxo_fixture(attrs \\ %{}) do
    {:ok, utxo} =
      attrs
      |> Enum.into(%{
        satoshis: 42,
        script: "76a9144d7eb7ce5ce099dd218383f3f81d3c2f1e48113f88ac",
        spent: true,
        spent_at: ~U[2025-04-18 21:13:00Z],
        txid: "9f797ad1ca0a8796a2f3464565d3cb34835725c81bc01ed3d9bfea67f733a4ab",
        vout: 7
      })
      |> Qart.Transactions.create_utxo()

    utxo
  end
end
