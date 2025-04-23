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

  # converts m/44'/236'/0'/0/3 to m_44^_236^_0^_0_3
  # when reading in paths, run the pattern match
  # then run the conversion to  m/44'/236'/0'/0/3
  # then verify a valid path
  # then do the intended action
  def parameterize_derivation_path(path) do
    Regex.replace(~r{['/]}, path, fn
      "'" -> "^"
      "/" -> "_"
    end)
  end
end
