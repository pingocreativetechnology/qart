defmodule Qart.Posts do
  import Ecto.Query
  alias Qart.Repo
  alias Qart.Posts.Post

  def create_post(attrs) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  def list_user_posts(user_id) do
    Post
    |> where(user_id: ^user_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def list_posts do
    query = from p in Post, order_by: [desc: p.inserted_at]
    Repo.all(query)
  end
end
