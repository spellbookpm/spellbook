defmodule Spellbook.Spells do
  @moduledoc """
  A module with utilities for installed spells.
  """
  @spells_dir Spellbook.Environment.spells_dir()

  alias Spellbook.Utils

  def find_spell(name) do
    spell =
      @spells_dir
      |> File.ls!()
      |> Enum.find(fn file -> Utils.is_match?(file, name) end)

    case spell do
      nil -> {:error, "Could not find spell in grimoire"}
      spell -> {:ok, Path.join(@spells_dir, spell)}
    end
  end

  def collect_spell_versions(spell_path) do
    versions =
      spell_path
      |> File.ls!()

    case versions do
      [] ->
        {:error, "No versions found"}

      _ ->
        {:ok, versions}
    end
  end
end
