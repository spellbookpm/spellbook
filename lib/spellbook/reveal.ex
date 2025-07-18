defmodule Spellbook.Reveal do
  @moduledoc """
  Module for containing the code to handle the reveal subcommand.
  """

  @behaviour Spellbook.Action

  @doc """
  Function handler called into my the CLI parser for handling the reveal subcommand.

  Performs a search of the stacks for a spell definition. If it exists, load it and
  print out information about the spell for the user.
  """
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
            IO.puts("---")
            IO.puts("name: #{module.name()}")
            IO.puts("description: #{module.description()}")
            IO.puts("version: #{module.version()}")
            IO.puts("type: #{module.type()}")
            IO.puts("homepage: #{module.homepage()}")
            IO.puts("license: #{module.license()}")
            IO.puts("---")

          _ ->
            IO.puts("Could not load module for #{spec}")
            :error
        end
    end
  end
end
