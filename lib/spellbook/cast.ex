defmodule Spellbook.Cast do
  @moduledoc """
  The module that is called in to for the cast subcommand. The main bit of code is the perform function
  which, in this case, handles the process of installing a specified 'spell' should it exist.

  Currently, this is done by pulling the source code for the project based on the spell specification
  and then setting up a temporary directory to build in, followed by building and installing into the
  appropriate paths.
  """

  @behaviour Spellbook.Action

  alias Spellbook.Builder
  alias Spellbook.Linker
  alias Spellbook.Spells
  alias Spellbook.Utils

  @doc """
   Function called by the cli to handle casting of a spell, or installing a requested package. 
  """
  def perform(args) do
    IO.puts("Warming up to perform cast...")
    IO.puts("Casting #{args}")

    with false <- Spells.does_spell_exist(args),
         {:ok, module} <- Builder.get_spell_specification(args),
         {:ok, build_path} <- Builder.setup_build_dir(module.name(), module.version()),
         {:ok, sources_path} <- Builder.get_build_sources(module.source(), build_path),
         sources_path <- Path.join(sources_path, module.name() <> "-" <> module.version()),
         install_prefix <- Utils.compute_install_prefix(module.name(), module.version()),
         :ok <- Builder.run_install(module, %{install_prefix: install_prefix, cwd: sources_path}) do
      Linker.link_spell(module.name(), module.version())
    else
      true ->
        IO.puts("Spell #{args} has already been casted.")
        :error

      {:error, message} ->
        IO.puts("Error: #{message}")
        :error

      _ ->
        IO.puts("An unknown error occured")
        :error
    end
  end
end
