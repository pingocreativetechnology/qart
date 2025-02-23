defmodule Qart.Follows do
  import Ecto.Query
  alias Qart.Repo
  alias Qart.Accounts.Follow

  def is_followed?(user_id, followed_user_id) do
    query =
      from f in Follow,
        where: f.user_id == ^user_id and f.followed_user_id == ^followed_user_id,
        select: count(f.id)

    Repo.one(query) > 0
  end

  def follow_user(user_id, followed_user_id) do
    %Follow{}
    |> Follow.changeset(%{user_id: user_id, followed_user_id: followed_user_id})
    |> Repo.insert(on_conflict: :nothing)
  end

  def unfollow_user(user_id, followed_user_id) do
    from(f in Follow,
      where: f.user_id == ^user_id and f.followed_user_id == ^followed_user_id
    )
    |> Repo.delete_all()
  end
end
