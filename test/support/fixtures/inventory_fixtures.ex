defmodule Qart.InventoryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Qart.Inventory` context.
  """

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        price: "120.5",
        status: "some status",
        tags: %{}
      })
      |> Qart.Inventory.create_item()

    item
  end
end
