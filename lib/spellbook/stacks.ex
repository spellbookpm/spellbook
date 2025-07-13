defmodule Spellbook.Stacks do
  @stacks Spellbook.Environment.the_stacks()
  @default_spellbook_repo Spellbook.Environment.default_spellbook_repo()
  @default_spellbook Spellbook.Environment.default_spell_book()

  def create_stacks() do
    if File.exists?(@stacks) == false do
      Spellbook.Utils.create_dir(@stacks)
    end
  end

  def contains_spellbooks() do
    create_stacks()

    if File.exists?(@stacks) do
      count =
        File.ls!(@stacks)
        |> Enum.count()

      dbg(count)

      if count > 0 do
        true
      else
        false
      end
    end
  end

  def contains_default_spellbook() do
    if File.exists?(@default_spellbook) do
      true
    else
      false
    end
  end

  def clone_default_spellbook() do
    create_stacks()
    IO.puts("Cloning #{@default_spellbook_repo} into #{@stacks}")
    Spellbook.GitOps.clone(@default_spellbook_repo, @stacks)
  end

  def update_default_spellbook() do
    if File.exists?(@default_spellbook) do
      Spellbook.GitOps.fetch_and_pull(@default_spellbook)
    end
  end
end
