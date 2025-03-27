defmodule Qart.Repo.Migrations.AddUserPublic do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :publish_public_profile, :boolean, default: false, doc: "enable this option to publish profile publicly"
      add :publish_public_items, :boolean, default: false, doc: "enable this option to publish ALL items publicly"
      add :publish_public_posts, :boolean, default: false, doc: "enable this option to publish ALL posts publicly"
    end
  end
end
