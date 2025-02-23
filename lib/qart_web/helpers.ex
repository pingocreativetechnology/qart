defmodule QartWeb.Helpers do
  @gradients [
    "from-red-500 via-yellow-500 to-pink-500",
    "from-blue-500 via-green-500 to-purple-500",
    "from-indigo-500 via-teal-500 to-cyan-500",
    "from-orange-500 via-rose-500 to-amber-500",
    "from-fuchsia-500 via-sky-500 to-lime-500"
  ]

  def get_gradient(string) do
    hash = :crypto.hash(:md5, string) |> :binary.decode_unsigned()
    Enum.at(@gradients, rem(hash, length(@gradients)))
  end
end
