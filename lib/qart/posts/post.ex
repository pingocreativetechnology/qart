defmodule Qart.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    belongs_to :user, Qart.Accounts.User
    field :content, :string
    field :attachments, {:array, :string}
    field :payment_amount, :decimal, default: 0.0
    field :txid, :string
    timestamps()
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:user_id, :content, :attachments, :payment_amount, :txid])
    |> validate_required([:user_id, :content])
  end
end
