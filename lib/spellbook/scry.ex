defmodule Spellbook.Scry do
  @moduledoc """
  Module containing code for performaing scry subcommand.

  The scry subcommand searchs for packages based on a given name
  and returns a list of packages that match with a jaro distance
  of >= 0.8. 
  """
  @behaviour Spellbook.Action

  alias Spellbook.Environment

  @doc """
  Handler for the scry subcommand.

  Expects args to contain a search term.
  """
  def perform(args) do
    IO.puts("Searching the stacks for #{args}...")
    stack_path = Environment.the_stacks()

    perform_search(stack_path, args)
    |> List.flatten()
    |> Enum.each(fn spell -> IO.puts(spell) end)

    IO.puts("Search complete...")
  end

  defp perform_search(dir, search_term) do
    dir
    |> File.ls!()
    |> Enum.reject(fn file -> file == ".git" end)
    |> Enum.map(fn file ->
      path = Path.join(dir, file)

      cond do
        File.dir?(path) ->
          perform_search(path, search_term)

        is_match?(path, search_term) ->
          path
          |> Path.basename()
          |> Path.rootname(".exs")

        true ->
          nil
      end
    end)
  end

  defp is_match?(file, search_term) do
    probable = Path.basename(file) |> Path.rootname(".exs")
    String.jaro_distance(probable, search_term) >= 0.8
  end
end
