defmodule Qart.ShoppingTest do
  use Qart.DataCase

  alias Qart.Shopping

  describe "carts" do
    alias Qart.Shopping.Cart

    import Qart.ShoppingFixtures

    @invalid_attrs %{}

    test "list_carts/0 returns all carts" do
      cart = cart_fixture()
      assert Shopping.list_carts() == [cart]
    end

    test "get_cart!/1 returns the cart with given id" do
      cart = cart_fixture()
      assert Shopping.get_cart!(cart.id) == cart
    end

    test "create_cart/1 with valid data creates a cart" do
      valid_attrs = %{}

      assert {:ok, %Cart{} = cart} = Shopping.create_cart(valid_attrs)
    end

    test "create_cart/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shopping.create_cart(@invalid_attrs)
    end

    test "update_cart/2 with valid data updates the cart" do
      cart = cart_fixture()
      update_attrs = %{}

      assert {:ok, %Cart{} = cart} = Shopping.update_cart(cart, update_attrs)
    end

    test "update_cart/2 with invalid data returns error changeset" do
      cart = cart_fixture()
      assert {:error, %Ecto.Changeset{}} = Shopping.update_cart(cart, @invalid_attrs)
      assert cart == Shopping.get_cart!(cart.id)
    end

    test "delete_cart/1 deletes the cart" do
      cart = cart_fixture()
      assert {:ok, %Cart{}} = Shopping.delete_cart(cart)
      assert_raise Ecto.NoResultsError, fn -> Shopping.get_cart!(cart.id) end
    end

    test "change_cart/1 returns a cart changeset" do
      cart = cart_fixture()
      assert %Ecto.Changeset{} = Shopping.change_cart(cart)
    end
  end

  describe "cart_items" do
    alias Qart.Shopping.CartItem

    import Qart.ShoppingFixtures

    @invalid_attrs %{quantity: nil}

    test "list_cart_items/0 returns all cart_items" do
      cart_item = cart_item_fixture()
      assert Shopping.list_cart_items() == [cart_item]
    end

    test "get_cart_item!/1 returns the cart_item with given id" do
      cart_item = cart_item_fixture()
      assert Shopping.get_cart_item!(cart_item.id) == cart_item
    end

    test "create_cart_item/1 with valid data creates a cart_item" do
      valid_attrs = %{quantity: 42}

      assert {:ok, %CartItem{} = cart_item} = Shopping.create_cart_item(valid_attrs)
      assert cart_item.quantity == 42
    end

    test "create_cart_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shopping.create_cart_item(@invalid_attrs)
    end

    test "update_cart_item/2 with valid data updates the cart_item" do
      cart_item = cart_item_fixture()
      update_attrs = %{quantity: 43}

      assert {:ok, %CartItem{} = cart_item} = Shopping.update_cart_item(cart_item, update_attrs)
      assert cart_item.quantity == 43
    end

    test "update_cart_item/2 with invalid data returns error changeset" do
      cart_item = cart_item_fixture()
      assert {:error, %Ecto.Changeset{}} = Shopping.update_cart_item(cart_item, @invalid_attrs)
      assert cart_item == Shopping.get_cart_item!(cart_item.id)
    end

    test "delete_cart_item/1 deletes the cart_item" do
      cart_item = cart_item_fixture()
      assert {:ok, %CartItem{}} = Shopping.delete_cart_item(cart_item)
      assert_raise Ecto.NoResultsError, fn -> Shopping.get_cart_item!(cart_item.id) end
    end

    test "change_cart_item/1 returns a cart_item changeset" do
      cart_item = cart_item_fixture()
      assert %Ecto.Changeset{} = Shopping.change_cart_item(cart_item)
    end
  end
end
