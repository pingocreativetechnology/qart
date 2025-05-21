defmodule Qart.Shopping do
  @moduledoc """
  The Shopping context.
  """

  import Ecto.Query, warn: false
  alias Qart.Repo
  alias Qart.Shopping.{Cart, CartItem}

  @doc """
  Returns the list of carts.

  ## Examples

      iex> list_carts()
      [%Cart{}, ...]

  """
  def list_carts do
    Repo.all(Cart)
  end

  @doc """
  Gets a single cart.

  Raises `Ecto.NoResultsError` if the Cart does not exist.

  ## Examples

      iex> get_cart!(123)
      %Cart{}

      iex> get_cart!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cart!(id), do: Repo.get!(Cart, id)

  @doc """
  Creates a cart.

  ## Examples

      iex> create_cart(%{field: value})
      {:ok, %Cart{}}

      iex> create_cart(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cart(attrs \\ %{}) do
    %Cart{}
    |> Cart.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cart.

  ## Examples

      iex> update_cart(cart, %{field: new_value})
      {:ok, %Cart{}}

      iex> update_cart(cart, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cart(%Cart{} = cart, attrs) do
    cart
    |> Cart.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cart.

  ## Examples

      iex> delete_cart(cart)
      {:ok, %Cart{}}

      iex> delete_cart(cart)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cart(%Cart{} = cart) do
    Repo.delete(cart)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cart changes.

  ## Examples

      iex> change_cart(cart)
      %Ecto.Changeset{data: %Cart{}}

  """
  def change_cart(%Cart{} = cart, attrs \\ %{}) do
    Cart.changeset(cart, attrs)
  end

  alias Qart.Shopping.CartItem

  @doc """
  Returns the list of cart_items.

  ## Examples

      iex> list_cart_items()
      [%CartItem{}, ...]

  """
  def list_cart_items do
    Repo.all(CartItem)
  end

  @doc """
  Gets a single cart_item.

  Raises `Ecto.NoResultsError` if the Cart item does not exist.

  ## Examples

      iex> get_cart_item!(123)
      %CartItem{}

      iex> get_cart_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cart_item(cart_id, item_id) do
    Repo.get_by(CartItem, cart_id: cart_id, item_id: item_id)
  end

  def get_cart_item!(id), do: Repo.get!(CartItem, id)

  @doc """
  Creates a cart_item.

  ## Examples

      iex> create_cart_item(%{field: value})
      {:ok, %CartItem{}}

      iex> create_cart_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cart_item(attrs \\ %{}) do
    %CartItem{}
    |> CartItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cart_item.

  ## Examples

      iex> update_cart_item(cart_item, %{field: new_value})
      {:ok, %CartItem{}}

      iex> update_cart_item(cart_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cart_item(%CartItem{} = cart_item, attrs) do
    cart_item
    |> CartItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cart_item.

  ## Examples

      iex> delete_cart_item(cart_item)
      {:ok, %CartItem{}}

      iex> delete_cart_item(cart_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cart_item(%CartItem{} = cart_item) do
    Repo.delete(cart_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cart_item changes.

  ## Examples

      iex> change_cart_item(cart_item)
      %Ecto.Changeset{data: %CartItem{}}

  """
  def change_cart_item(%CartItem{} = cart_item, attrs \\ %{}) do
    CartItem.changeset(cart_item, attrs)
  end


  # USER-RELATED FUNCTIONS #####################################################

  def get_or_create_cart(nil), do: {:error, "No user session"}
  def get_or_create_cart(user_id) do
    Repo.get_by(Cart, user_id: user_id) ||
      %Cart{}
      |> Cart.changeset(%{user_id: user_id})
      |> Repo.insert!()
  end

  def add_to_cart(user_id, item_id, quantity \\ 1) do
    cart = get_or_create_cart(user_id)

    case Repo.get_by(CartItem, cart_id: cart.id, item_id: item_id) do
      nil ->
        %CartItem{}
        |> CartItem.changeset(%{cart_id: cart.id, item_id: item_id, quantity: quantity})
        |> Repo.insert()


      _cart_item ->
        {:error, :already_in_cart}

      cart_item ->
        cart_item
        |> CartItem.changeset(%{quantity: cart_item. quantity + quantity})
        |> Repo.update()
    end
  end

  # Get all cart items for a user
  def get_user_cart_items(user_id) do
    cart = get_or_create_cart(user_id)

    Repo.all(
      from ci in CartItem,
      where: ci.cart_id == ^cart.id,
      preload: [item: :user]
    )
  end

  def get_cart_items(cart_id) do
    Repo.all(from ci in CartItem, where: ci.cart_id == ^cart_id, preload: [:item])
  end

  # Remove an item from the cart
  def remove_from_cart(user_id, item_id) do
    cart = get_or_create_cart(user_id)

    # deletion =
    case from(ci in CartItem, where: ci.cart_id == ^cart.id and ci.item_id == ^item_id)
    |> Repo.delete_all() do
      {id, nil} ->
        {:ok, id}

      _ ->
        IO.inspect("something else")
        {:error, :not_in_cart}
    end

  end

  def empty_cart(user_id) do
    cart = get_or_create_cart(user_id)

    from(ci in CartItem, where: ci.cart_id == ^cart.id)
    |> Repo.delete_all()
  end

  def get_cart_total(cart_id, tax_rate \\ 0.075) do
    excise_tax_rate = 0.15
    shipping_cost = 5

    payees = []

    cart_items =
      Repo.all(
        from ci in CartItem,
        join: i in assoc(ci, :item),
        where: ci.cart_id == ^cart_id,
        select: {i.price, ci.quantity}
      )

    line_items =
      Repo.all(
        from ci in CartItem,
        where: ci.cart_id == ^cart_id,
        preload: [item: :user]
      )

    payees = line_items
      |> Enum.map(fn cart_item -> %{user_email: cart_item.item.user.email} end)

    payees = line_items
      |> Enum.map(fn cart_item -> %{user_email: cart_item.item.user.email} end)

    subtotal =
      Enum.reduce(cart_items, Decimal.new("0.00"), fn {price, quantity}, acc ->
        acc
        |> Decimal.add(Decimal.mult(price, Decimal.new(quantity)))
      end)

    sales_tax = Decimal.new Decimal.mult(subtotal, Decimal.from_float(tax_rate)) |> Decimal.round(2)

    excise_tax = Decimal.new Decimal.mult(subtotal, Decimal.from_float(excise_tax_rate)) |> Decimal.round(2)

    total = Decimal.add(subtotal, sales_tax)
      |> Decimal.add(excise_tax)
      |> Decimal.add(shipping_cost)
      |> Decimal.round(2)

    %{
      payees: payees,
      subtotal: subtotal,
      sales_tax: sales_tax,
      excise_tax: excise_tax,
      total: total
    }
  end

end
