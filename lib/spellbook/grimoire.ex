defmodule Spellbook.Grimoire do
  @moduledoc """
  Module for the grimoire subcommand.

  This subcommand lists all casted, or installed, spells (packages).
  """
  @behaviour Spellbook.Action

  alias Spellbook.Spells

  @doc """
  Function called by the CLI entry point to perform a listing is casted spells.

  Gets all directories at `$PREFIX/Spells` and flattens the output to be printed.
  """
  def perform(%{args: %{spell: spell}}) do
    if spell == nil do
      list_all()
      :ok
    else
      get_versions(spell) 
      :ok
    end
  end

  defp get_versions(spell) do
    IO.puts("Listing versions for spell: #{spell}")
    
    with {:ok, spell_path} <- Spells.find_spell(spell),
         {:ok, versions} <- Spells.collect_spell_versions(spell_path) do
      versions
      |> Enum.each(fn version -> IO.puts("\t#{version}") end)
    else
      {:error, message} ->
          IO.puts("Error: #{message}")
    end
  end

  defp list_all() do
    Spellbook.Environment.spells_dir()
    |> File.ls!()
    |> List.flatten()
    |> Enum.each(fn entry -> IO.puts(entry) end)
  end

end
