defmodule Spellbook.Grimoire do
  @moduledoc """
  Module for the grimoire subcommand.

  This subcommand lists all casted, or installed, spells (packages).
  """
  @behaviour Spellbook.Action

  @doc """
  Function called by the CLI entry point to perform a listing is casted spells.

  Gets all directories at `$PREFIX/Spells` and flattens the output to be printed.
  """
  def perform(_args) do
    Spellbook.Environment.spells_dir()
    |> File.ls!()
    |> List.flatten()
    |> Enum.each(fn entry -> IO.puts(entry) end)
  end
end
