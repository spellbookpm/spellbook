defmodule Spellbook.Environment do
  def prefix(), do: System.get_env("SPELLBOOK_PREFIX") || "/opt/spellbook"
  def shelves_dir(), do: System.get_env("SPELLBOOK_SHELVES") || "#{spells_dir()}/Shelves"

  def default_spell_book(),
    do: System.get_env("SPELLBOOK_DEFAULT_BOOK") || "#{shelves_dir()}/StandardBookOfSpells"

  def spells_dir(), do: System.get_env("SPELLBOOK_SPELLS") || "#{prefix()}/Spells"
  def temp_dir(), do: System.get_env("SPELLBOOK_TEMP") || System.tmp_dir!()

  def all do
    %{
      prefix: prefix(),
      spells_dir: spells_dir(),
      shelves_dir: shelves_dir(),
      default_spell_book: default_spell_book(),
      temp_dir: temp_dir()
    }
  end
end
