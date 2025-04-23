defmodule Qart.Repo.Migrations.AddWalletNotes do
  use Ecto.Migration

  def change do
     alter table("wallets") do
      add :name, :string, comment: "user-provided name"
      add :description, :string, comment: "user-provided description"
      add :notes, :text, comment: "user-provided notes"
      add :code, :text, comment: "user-provided code, maybe a gist to augment a wallet"
    end
  end
end
