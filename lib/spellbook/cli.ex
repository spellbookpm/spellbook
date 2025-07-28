defmodule Spellbook.CLI do
  @moduledoc """
  Module for handling the command line arguments and parsing for the spellbook command-line interface.
  """

  @version "0.0.1"

  @doc """
  Main entry point to be called by the binary.
  """
  def main(args) do
    optimus =
      Optimus.new!(
        name: "spellbook",
        description: "Magical system package manager",
        version: @version,
        author: "Todd Martin",
        about: "A magical system package manager",
        allow_unknown_args: false,
        parse_double_dash: true,
        subcommands: [
          cast: [
            name: "cast",
            about: "Cast (install) a spell (package)",
            args: [
              spell: [
                value_name: "SPELL",
                help: "Package",
                required: true,
                parser: :string
              ]
            ]
          ],
          dispel: [
            name: "dispel",
            about: "Dispel (uninstall) a spell (package)",
            args: [
              spell: [
                value_name: "SPELL",
                help: "Package",
                required: true,
                parser: :string
              ]
            ]
          ],
          scry: [
            name: "scry",
            about: "Search for a spell",
            args: [
              term: [
                value_name: "TERM",
                help: "Scrying term",
                required: true,
                parser: :string
              ]
            ]
          ],
          grimoire: [
            name: "grimoire",
            about: "List casted spells",
            args: [
              spell: [
                value_name: "SPELL",
                help: "Check grimoire for spell",
                required: false,
                parser: :string
              ]
            ]
          ],
          reveal: [
            name: "reveal",
            about: "Reveal information about a spell",
            args: [
              spell: [
                value_name: "SPELL",
                help: "PACKAGE",
                required: true,
                parser: :string
              ]
            ]
          ],
          renew: [
            name: "renew",
            about: "Renew your spellbook shelf"
          ],
          empower: [
            name: "empower",
            about: "Upgrade a casted spell",
            args: [
              spell: [
                value_name: "SPELL",
                help: "PACKAGE (Optional; for only empowering a single spell)",
                required: false,
                parser: :string
              ]
            ],
            flags: [
              all: [
                long: "--all",
                help: "Empower all spells",
                multiple: false
              ]
            ]
          ],
          bind: [
            name: "bind",
            about: "Utilize a specific version of a spell",
            args: [
              spell: [
                value_name: "SPELL",
                help: "Name of packafe",
                required: true,
                parse: :string
              ],
              version: [
                value_name: "VERSION",
                help: "Version to use",
                required: true,
                parse: :string
              ]
            ]
          ]
        ]
      )

    case Optimus.parse(optimus, args) do
      :help ->
        IO.puts(Optimus.help(optimus))

      {:help, [subcommand]} ->
        # dbg(subcommand)
        # dbg(optimus.subcommands)
        Enum.find(optimus.subcommands, fn sub -> sub.subcommand == subcommand end)
        |> Optimus.help()
        |> IO.puts()

      {:ok, subcommand, args} ->
        handle(subcommand, args)

      # {:error, subcommand, message} ->
      _ ->
        IO.puts(Optimus.help(optimus))
    end
  end

  @doc """
  Funtion for handling the cast subcommand.
  """
  defp handle([:cast], %{args: %{spell: spell}}) do
    IO.puts("Casting spell: #{spell}")
    Spellbook.Cast.perform(spell)
  end

  @doc """
  Function for handling the dispel subcommand.
  """
  defp handle([:dispel], %{args: %{spell: spell}}) do
    IO.puts("Dispelling spell: #{spell}")
    Spellbook.Dispel.perform(spell)
  end

  @doc """
  Function for handling the scry sub command.
  """
  defp handle([:scry], %{args: %{term: term}}) do
    IO.puts("Scrying #{term}")
    Spellbook.Scry.perform(term)
  end

  @doc """
  Function for handling the grimoire subcommand.
  """
  defp handle([:grimoire], args) do
    IO.puts("Listing spells from your grimoire")
    Spellbook.Grimoire.perform(args)
  end

  @doc """
  Function for handling the reveal subcommand.
  """
  defp handle([:reveal], %{args: %{spell: spell}}) do
    IO.puts("Revealing spell: #{spell}")
    Spellbook.Reveal.perform(spell)
  end

  @doc """
  Function for handling the renew subcommand.
  """
  defp handle([:renew], args) do
    IO.puts("Renewing the stacks...")
    Spellbook.Renew.perform(args)
  end

  @doc """
  Function for handling the renrew subcommand.
  """
  defp handle([:empower], %{args: %{spell: spell}, flags: %{all: all}}) do
    Spellbook.Empower.perform(%{spell: spell, all: all})
  end

  defp handle([:bind], %{args: %{spell: spell, version: version}}) do
    Spellbook.Bind.perform(spell, version)
  end
end
