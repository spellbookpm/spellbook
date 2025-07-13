defmodule Spellbook.Scry do
  @behaviour Spellbook.Action

  alias Spellbook.Environment

  alias Spellbook.Stacks

  def perform(args) do
    IO.puts("Searching the stacks for #{args}...")
    stack_path = Environment.the_stacks()

    stack_path
    |> File.ls!()
    |> Enum.filter(fn file -> file != ".git" end)
    |> Enum.map(fn file -> stack_path <> "/" <> file end)
    |> Enum.each(fn file ->
      if File.dir?(file) do
        perform_search(file, args) 
      end
    end)

    IO.puts("Search complete...")
  end

  defp perform_search(dir, search_term) do
    dir
    |> File.ls!()
    |> Enum.filter(fn file -> file != ".git" end)
    |> Enum.map(fn file -> dir <> "/" <> file end)
    |> Enum.each(fn file ->
      if File.dir?(file) do
        perform_search(file, search_term)
      else
        term = file 
          |> Path.basename()
          |> Path.rootname()
        if String.jaro_distance(term, search_term) > 0.8 do
          IO.puts("#{term}")
        end
      end
    end)
  end
end
