defmodule Spellbook.Bind do
  @moduledoc """
  Module for the bind subcommand. 

  This subcommand can be used to swap between different versions for an installed spell.
  """
  @behaviour Spellbook.Action

  alias Spellbook.Linker
  alias Spellbook.Spells


  def perform(spell, version) do
    IO.puts("Swapping #{spell} to use #{version}")
    with {:ok, spell_path} <- Spells.find_spell(spell),
         {:ok, versions} <- Spells.collect_spell_versions(spell_path), 
         true <- contains_version?(versions, version) do
      Linker.link_spell(spell, version)
      :ok 
    else
      {:error, message} ->
        IO.puts("Error: #{message}")
        :error

      _ ->
        IO.puts("An error occured,")
        :error
    end
  end

  defp contains_version?(versions, version) do
    versions
      |> Enum.member?(version)
  end
end
