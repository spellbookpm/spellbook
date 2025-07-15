defmodule Spellbook.Dispel do
  @moduledoc """
  Module for handling the dispeling of a spell, or uninstalling. Called into from the main cli file that
  parses and handles the command line arguments.
  """
  @bheavious Spellbook.Action

  alias Spellbook.Environment
  alias Spellbook.Utils

  @doc """
  Handle the dispel subcommand.

  Searches for if the spell is installed by checking `$PREFIX/Spells`. If found. collect the version(s) and
  get a list of files to be removed. Remove the files and finally the Spell's directory.
  """
  def perform(args) do
    with {:ok, spell} <- search_for_spell(args),
         spell_path <- Path.join(Environment.spells_dir(), spell),
         {:ok, versions} <- collect_versions(spell_path),
         version_paths <- Enum.map(versions, fn version -> Path.join(spell_path, version) end),
         {:ok, version_path} <- get_first(version_paths),
         files_map <- Enum.map(version_paths, fn path -> collect_artifacts(path) end),
         files <- List.flatten(files_map),
         non_rooted_files <-
           Enum.map(files, fn entry -> String.replace(entry, version_path, "") end) do
      non_rooted_files
      |> Enum.map(fn entry -> Path.join(Environment.prefix(), entry) end)
      |> Utils.remove_files()

      Utils.rm_rf(spell_path)

      IO.puts("Removal complete")
    else
      {:error, message} ->
        IO.puts("Spell not found: #{args}")
    end
  end

  @doc """
  Entry point for a resursive search for a spell.

  Requires a name, name of the spell to search for.

  Returns a list of spells that match the name.
  """
  defp search_for_spell(name) do
    spell =
      Environment.spells_dir()
      |> File.ls!()
      |> Enum.find(fn file -> Utils.is_match?(file, name) end)

    case spell do
      nil -> {:error, "#{name} not found"}
      match -> {:ok, match}
    end
  end

  @doc """
  Get the first entry in a list.

  Requires a list.

  Returns an error with a message if the list does not contain any entries.
  If it contains entries, return the first entry with an ok.
  """
  defp get_first(list) do
    case List.first(list) do
      nil ->
        {:error, "No entries in list"}

      entry ->
        {:ok, entry}
    end
  end

  @doc """
  Get a list of version for a spell, given its path.

  Requires a root_path, which is the path to the directory of a given spell.

  Returns ok with a list of versions, if there are versions within. Otherwise,
  return an error with a message.
  """
  defp collect_versions(root_path) do
    versions =
      root_path
      |> File.ls!()

    case Enum.empty?(versions) do
      true ->
        {:error, "No versions listed"}

      false ->
        {:ok, versions}
    end
  end

  @doc """
  Recursive each and collection of build artifacts from a spell.

  Requires a dir, the path to the installed spell of its version.

  Return a list of files with their path of build artifacts.
  """
  defp collect_artifacts(dir) do
    dir
    |> File.ls!()
    |> Enum.map(fn file ->
      path = Path.join(dir, file)

      cond do
        File.dir?(path) ->
          collect_artifacts(path)

        File.regular?(path) ->
          path

        true ->
          nil
      end
    end)
  end
end
