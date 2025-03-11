defmodule Qart.Repo.Migrations.AddEncryptedFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :encrypted_seed, :binary
    end
  end
end
