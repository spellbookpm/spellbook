defmodule Spellbook.Bind do
  @moduledoc """
  Module for the bind subcommand. 

  This subcommand can be used to swap between different versions for an installed spell.
  """
  @behaviour Spellbook.Action

  alias Spellbook.Linker
  alias Spellbook.Spells

  def perform(args) do
    IO.puts("Swapping #{args.spell} to use #{args.version}")

    with {:ok, spell_path} <- Spells.find_spell(args.spell),
         {:ok, versions} <- Spells.collect_spell_versions(spell_path),
         true <- contains_version?(versions, args.version) do
      Linker.link_spell(args.spell, args.version)
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
