defmodule Spellbook.Empower do
  @behaviour Spellbook.Action

  alias Spellbook.Builder
  alias Spellbook.Linker
  alias Spellbook.Spells
  alias Spellbook.Utils

  def perform(args) do
    if args.all == true do
      IO.puts("Empowering all...")
    else
      empower_spell(args.spell)
    end
  end

  def empower_all() do
    # TODO: To do later
    IO.puts("Currently an unsupported operation... WIP.")
  end

  def empower_spell(spell) do
    IO.puts("Empowering #{spell}")

    with {:ok, spell_dir} <- Spells.find_spell(spell),
         {:ok, spell_versions} <- Spells.collect_spell_versions(spell_dir),
         {:ok, stack_version} <- get_stack_version(spell),
         false <- Enum.member?(spell_versions, stack_version) do
      case Utils.yes_no_prompt("Would you like to empower #{spell} to #{}?") do
        :yes ->
          IO.puts("Starting empowerment...")
          install_spell(spell)

        :no ->
          IO.puts("Shutting down empowerment...")

        :unsupported_input ->
          IO.puts("Shutting down empowerment. Invalid input to prompt.")
      end
    else
      true ->
        IO.puts("Spell is already casted with the latest version.")

      :error ->
        IO.puts("Error")

      {:error, message} ->
        IO.puts("Error: #{message}")
    end
  end

  defp install_spell(spell) do
    with {:ok, module} <- Builder.get_spell_specification(spell),
         {:ok, build_path} <- Builder.setup_build_dir(module.name(), module.version()),
         {:ok, sources_path} <- Builder.get_build_sources(module.source(), build_path),
         sources_path <- Path.join(sources_path, module.name() <> "-" <> module.version()),
         install_prefix <- Utils.compute_install_prefix(module.name(), module.version()),
         :ok <- Builder.run_install(module, %{install_prefix: install_prefix, cwd: sources_path}) do
      Linker.link_spell(module.name(), module.version())
    else
      {:error, message} ->
        IO.puts("Error: #{message}")
        :error

      _ ->
        IO.puts("An unknown error occured")
        :error
    end
  end

  defp get_stack_version(spell) do
    with spell_spec <- Spellbook.Stacks.search_stacks_get_first(spell),
         [{module, _binary}] <- Code.compile_file(spell_spec) do
      {:ok, module.version()}
    else
      _ -> {:error, "Could not find spell in the stacks"}
    end
  end
end
