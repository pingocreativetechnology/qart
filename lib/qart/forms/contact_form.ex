defmodule Qart.Forms.ContactForm do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :name, :string
    field :email, :string
    field :message, :string
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:name, :email, :message])
    |> validate_required([:name, :email, :message])
    |> validate_format(:email, ~r/@/, message: "Invalid email format")
  end
end
