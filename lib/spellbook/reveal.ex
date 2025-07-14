defmodule Spellbook.Reveal do
  @behaviour Spellbook.Action

  def perform(args) do
    IO.puts("Search stacks for #{args}")

    case Spellbook.Stacks.search_stacks(args)
         |> List.first() do
      nil ->
        IO.puts("No spell found for #{args}")
        :error

      spec ->
        case Code.load_file(spec) do
          [{module, _binary}] ->
            IO.puts("name: #{module.name()}")
            IO.puts("version: #{module.version()}")
            IO.puts("type: #{module.type()}")
            IO.puts("homepage: #{module.homepage()}")
            IO.puts("license: #{module.license()}")

          _ ->
            IO.puts("Could not load module for #{spec}")
            :error
        end
    end
  end
end
