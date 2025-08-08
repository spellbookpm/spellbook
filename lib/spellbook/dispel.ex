defmodule Spellbook.Dispel do
  @moduledoc """
  Module for handling the dispeling of a spell, or uninstalling. Called into from the main cli file that
  parses and handles the command line arguments.
  """
  @behaviour Spellbook.Action

  alias Spellbook.Environment
  alias Spellbook.Utils

  @doc """
  Handle the dispel subcommand.

  Searches for if the spell is installed by checking `$PREFIX/Spells`. If found. collect the version(s) and
  get a list of files to be removed. Remove the files and finally the Spell's directory.
  """
  def perform(args) do
    with {:ok, spell} <- search_for_spell(args),
         :yes <- Utils.yes_no_prompt("Are you sure you want to dispel #{args}?"),
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
      :no ->
        IO.puts("Canceling cast.....")
      _ ->
        IO.puts("Spell not found: #{args}")
    end
  end

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

  defp get_first(list) do
    case List.first(list) do
      nil ->
        {:error, "No entries in list"}

      entry ->
        {:ok, entry}
    end
  end

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
