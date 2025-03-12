defmodule Qart.Repo.Migrations.AddUserProvider do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :provider, :string
      add :provider_uid, :string
    end
  end
end
