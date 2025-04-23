defmodule Qart.Transactions do
  @moduledoc """
  The Transactions context.
  """
  require IEx

  import Ecto.Query, warn: false
  alias Qart.Repo

  alias Qart.Transactions.Transaction

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions()
      [%Transaction{}, ...]

  """
  def list_transactions do
    Repo.all(Transaction)
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)


  def get_transaction_by_txid!(txid), do: Repo.get_by(Transaction, txid: txid)

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end


  # JungleBus functions ########################################################
  def parse_transaction do
    txid = "6e93e17cf98c1af0f851454e984942d72704412369e8b85ca74262285857b2d4"
    transaction = "AQAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP////8XA52NDS9DVVZWRS9LyH9b7vhTJywAAAD/////Ac5toBIAAAAAGXapFNZIaGz2A8EYUPOWAONzEnOKzMqPiKwAAAAA"
    z = BSV.Tx.from_binary(transaction, encoding: :base64)
    z
  end


  alias Qart.Transactions.Utxo

  @doc """
  Returns the list of utxos.

  ## Examples

      iex> list_utxos()
      [%Utxo{}, ...]

  """
  def list_utxos do
    Repo.all(Utxo)
  end

  def list_utxos_by_address(address) do
    Repo.all(from i in Utxo, where: i.address == ^address)
  end

  @doc """
  Gets a single utxo.

  Raises `Ecto.NoResultsError` if the Utxo does not exist.

  ## Examples

      iex> get_utxo!(123)
      %Utxo{}

      iex> get_utxo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_utxo!(id), do: Repo.get!(Utxo, id)

  @doc """
  Creates a utxo.

  ## Examples

      iex> create_utxo(%{field: value})
      {:ok, %Utxo{}}

      iex> create_utxo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_utxo(attrs \\ %{}) do
    %Utxo{}
    |> Utxo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a utxo.

  ## Examples

      iex> update_utxo(utxo, %{field: new_value})
      {:ok, %Utxo{}}

      iex> update_utxo(utxo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_utxo(%Utxo{} = utxo, attrs) do
    utxo
    |> Utxo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a utxo.

  ## Examples

      iex> delete_utxo(utxo)
      {:ok, %Utxo{}}

      iex> delete_utxo(utxo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_utxo(%Utxo{} = utxo) do
    Repo.delete(utxo)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking utxo changes.

  ## Examples

      iex> change_utxo(utxo)
      %Ecto.Changeset{data: %Utxo{}}

  """
  def change_utxo(%Utxo{} = utxo, attrs \\ %{}) do
    Utxo.changeset(utxo, attrs)
  end
end
