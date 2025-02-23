defmodule Qart do
  @moduledoc """
  Qart keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def debug(object) do
    IO.puts "------------------------------->"
    IO.inspect(object)
    IO.puts "-------------------------------|"
  end
end
