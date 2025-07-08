defmodule Spellbook.CLI do
  @version "0.0.1"

  def main(args) do
    optimus = Optimus.new!(
      name: "spellbook",
      description: "Magical system package manager",
      version: @version,
      author: "Todd Martin",
      about: "A magical system package manager",
      allow_unknown_args: false,
      parse_double_dash: true,
      flags: [
        version: [
          short: "-v",
          long: "--version",
          help: "Show the version number",
          multiple: false
        ]
      ],
      subcommands: [
        cast: [
          name: "cast",
          about: "Cast (install) a spell (package)",
          args: [
            spell: [
              value_name: "SPELL",
              help: "Cast (install) a spell (package)",
              required: true,
              parser: :string
            ]
          ]
        ]
      ]
    )

    case Optimus.parse(optimus, args) do
      :help -> IO.puts(Optimus.help(optimus))
      :version -> IO.puts("spellbook version #{@version}")
      {:ok, [subcommand], cast_result} ->
        case subcommand do
          :cast -> handle_cast(cast_result)
          :help -> IO.puts(Optimus.help(optimus))
          _ -> IO.puts("Unknown command: #{subcommand}")
        end
      {:ok, _parse_result} ->
        IO.puts(Optimus.help(optimus))
      {:error, message} -> 
        IO.puts("Error: #{message}")
    end
  end

  defp handle_cast(%{args: %{spell: spell}}) do
    # IO.puts("Casting spell: #{spell}")
    Spellbook.Cast.perform(spell)
  end

end

