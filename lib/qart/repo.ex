defmodule Qart.Repo do
  use Ecto.Repo,
    otp_app: :qart,
    adapter: Ecto.Adapters.Postgres
end
