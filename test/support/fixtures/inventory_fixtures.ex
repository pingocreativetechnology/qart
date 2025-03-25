defmodule Qart.InventoryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Qart.Inventory` context.
  """

  import Qart.UserFixtures

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    user = user_fixture(:user)

    {:ok, item} =
      attrs
      |> Enum.into(%{
        user_id: user.id,
        description: "some description",
        name: "some name",
        price: "120.5",
        status: "some status",
        tags: ["this", "that"]
      })
      |> Qart.Inventory.create_item()

    item
      |> Qart.Repo.preload(:user)
      |> Qart.Inventory.maybe_compute_user_virtuals
  end
end
