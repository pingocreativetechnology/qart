defmodule Qart.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string
      add :description, :text
      add :price, :decimal
      add :tags, :map
      add :images, :map
      add :status, :string

      timestamps(type: :utc_datetime)
    end
  end
end
