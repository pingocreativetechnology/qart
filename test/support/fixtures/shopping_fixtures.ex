defmodule Qart.ShoppingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Qart.Shopping` context.
  """

  import Qart.UserFixtures
  import Qart.InventoryFixtures

  @doc """
  Generate a cart.
  """
  def cart_fixture(attrs \\ %{}) do
    user = user_fixture()

    {:ok, cart} =
      attrs
      |> Enum.into(%{
        user_id: user.id
      })
      |> Qart.Shopping.create_cart()

    cart
  end

  @doc """
  Generate a cart_item.
  """
  def cart_item_fixture(attrs \\ %{}) do
    cart = cart_fixture()
    item = item_fixture()

    {:ok, cart_item} =
      attrs
      |> Enum.into(%{
        cart_id: cart.id,
        item_id: item.id,
        quantity: 42
      })
      |> Qart.Shopping.create_cart_item()

    cart_item
  end
end
