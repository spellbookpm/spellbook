defmodule Spellbook.Environment do
  def prefix(), do: System.get_env("SPELLBOOK_PREFIX") || "/opt/spellbook"
  def the_stacks(), do: System.get_env("SPELLBOOK_THE_STACKS") || "#{prefix()}/TheStacks"

  def default_spell_book(),
    do: System.get_env("SPELLBOOK_DEFAULT_BOOK") || "#{the_stacks()}/StandardBookOfSpells"

  def spells_dir(), do: System.get_env("SPELLBOOK_SPELLS") || "#{prefix()}/Spells"
  def temp_dir(), do: System.get_env("SPELLBOOK_TEMP") || System.tmp_dir!()

  def default_spellbook_repo,
    do:
      System.get_env("SPELLBOOK_DEFAULT_SPELLBOOK_REPO") ||
        "https://github.com/spellbookpm/StandardBookOfSpells.git"

  def all do
    %{
      prefix: prefix(),
      spells_dir: spells_dir(),
      shelves_dir: the_stacks(),
      default_spell_book: default_spell_book(),
      temp_dir: temp_dir()
    }
  end
end
