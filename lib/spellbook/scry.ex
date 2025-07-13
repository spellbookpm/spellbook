defmodule Spellbook.Scry do
  @behaviour Spellbook.Action

  alias Spellbook.Environment

  alias Spellbook.Stacks

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
