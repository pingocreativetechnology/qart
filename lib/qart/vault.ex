defmodule Qart.Vault do
  use Cloak.Vault, otp_app: :qart
end

defmodule Qart.Encrypted.Binary do
  use Cloak.Ecto.Binary, vault: Qart.Vault
end
