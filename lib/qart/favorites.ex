defmodule Qart.Favorites do
  import Ecto.Query
  alias Qart.Repo
  alias Qart.Accounts.Favorite

  # Check if an item is favorited
  def is_favorited?(user_id, item_id) do
    query =
      from f in Favorite,
        where: f.user_id == ^user_id and f.item_id == ^item_id,
        select: count(f.id)

    Repo.one(query) > 0
  end

  # Add an item to favorites
  def favorite_item(user_id, item_id) do
    %Favorite{}
    |> Favorite.changeset(%{user_id: user_id, item_id: item_id})
    |> Repo.insert(on_conflict: :nothing)
  end

  # Remove an item from favorites
  def unfavorite_item(user_id, item_id) do
    from(f in Favorite,
      where: f.user_id == ^user_id and f.item_id == ^item_id
    )
    |> Repo.delete_all()
  end
end
