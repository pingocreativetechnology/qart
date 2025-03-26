defmodule Qart.UserFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Qart.User` context.
  """

  @doc """
  Generate a user.
  """

  alias Qart.Accounts

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      Accounts.create_user(%{
        email: "user#{System.unique_integer()}@lvh.me",
        password: "passwordpassword"
      })

    user
  end
end
