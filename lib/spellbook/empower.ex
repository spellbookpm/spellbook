defmodule Spellbook.Empower do
  @behaviour Spellbook.Action

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
    IO.puts("To do later")
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
        :no ->
          IO.puts("Shutting down empowerment...")
        :unsupported_unput ->
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

  defp get_stack_version(spell) do
    with spell_spec <- Spellbook.Stacks.search_stacks_get_first(spell),
         [{module, _binary}] <- Code.load_file(spell_spec) do
      # dbg(spell_spec)
      {:ok, module.version()}
    else
      _ -> {:error, "Could not find spell in the stacks"}
    end
  end
end
