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
        raw: "some raw",
        spent: true,
        txid: "some txid",
        version: "some version"
      })
      |> Qart.Transactions.create_transaction()

    transaction
  end
end
