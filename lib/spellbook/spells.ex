defmodule Spellbook.Spells do
  @moduledoc """
  A module with utilities for installed spells.
  """
  @spells_dir Spellbook.Environment.spells_dir()

  alias Spellbook.Utils

  @doc """
  Finds a spell in the spells directory

  Requires a name, name of the spell

  Returns ok and the path to the spell on success
  Returns an error with a message if the spell is not found
  """
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

  @doc """
  Checks to see if a spell is already casted by checking the Spells directory

  Requires a name, name of the spell

  Returns true if it exists, false if not
  """
  def does_spell_exist(name) do
    @spells_dir
    |> File.ls!()
    |> Enum.member?(name)
  end

  @doc """
  Collects a list of installed spell versions

  Requires a spell path, path to a spell

  Returns ok and a list of versions is there are any
  Returns error with a message if no versions are present 
  """
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
