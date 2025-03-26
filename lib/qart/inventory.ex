defmodule Qart.Inventory do
  @moduledoc """
  The Inventory context.
  """

  import Ecto.Query, warn: false
  alias Qart.Repo

  alias Qart.Inventory.Item

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Repo.all(Item)
      |> Repo.preload(:user)
      |> Enum.map(&maybe_compute_user_virtuals/1)
  end

  def list_user_items(user_id) do
    Item
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  def list_items_by_tag(tag_name) do
    from(i in Item,
      where: ^tag_name in i.tags
    )
    |> Repo.all()
    |> Repo.preload(:user)
    |> Enum.map(&maybe_compute_user_virtuals/1)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id),
    do: Repo.get!(Item, id)
      |> Repo.preload(:user)
      |> maybe_compute_user_virtuals()

  def maybe_compute_user_virtuals(%Item{user: user} = item) when not is_nil(user) do
    %{item | user: Qart.Accounts.maybe_compute_display_name(user)}
  end

  def maybe_compute_user_virtuals(item), do: item

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    case %Item{}
      |> Item.changeset(attrs)
      |> Repo.insert() do

      {:ok, item} ->
        item = item
        |> Repo.preload(:user)
        |> maybe_compute_user_virtuals()

        {:ok, item}

      {:error, %Ecto.Changeset{}} ->
        {:error, %Ecto.Changeset{}}
    end
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end
end
