defmodule Spellbook do
  @moduledoc """
  Documentation for `Spellbook`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Spellbook.hello()
      :world

  """
  def hello do
    :world
  end

  def main(args) do
    Spellbook.CLI.main(args)
  end

end
