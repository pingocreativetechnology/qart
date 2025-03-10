defmodule Qart.Utils do
  @moduledoc """
  Utility functions for use across the application.
  """

  @doc """
  Removes the first element from a list. Returns an empty list if given an empty list.
  ## Examples

      iex> MyApp.Utils.drop_first([1, 2, 3])
      [2, 3]

      iex> MyApp.Utils.drop_first([])
      []
  """
  def drop_first([]), do: []
  def drop_first([_first | rest]), do: rest
end
