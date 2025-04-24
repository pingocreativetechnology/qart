# test/support/factory.ex
defmodule Qart.Factory do
  use ExMachina.Ecto, repo: Qart.Repo

  def user_factory do
    %Qart.Accounts.User{
      email: sequence(:email, &"user#{&1}@example.com"),
      hashed_password: Bcrypt.hash_pwd_salt("password")
    }
  end
end
