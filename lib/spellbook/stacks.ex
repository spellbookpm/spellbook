defmodule Spellbook.Stacks do
  @moduledoc """
  The module for working the the Stacks in spell.

  The stacks are repositories of spell defintions.
  """
  @stacks Spellbook.Environment.the_stacks()
  @default_spellbook_repo Spellbook.Environment.default_spellbook_repo()
  @default_spellbook Spellbook.Environment.default_spell_book()

  @doc """
  Creates the path for TheStacks if not present.

  The stacks should be at `$PREFIX/` where usually the `$PREFIX` is
  `/opt/spellbook/`.
  """
  def create_stacks() do
    if File.exists?(@stacks) == false do
      Spellbook.Utils.create_dir(@stacks)
    end
  end

  @doc """
  Checks to see if `TheStacks` contains a Spellbook, or repository of
  Spell definition.

  Returns true if `$PREFIX/TheStacks` contains files, otherwise returns false. 
  """
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

  @doc """
  Checks to see if the default repository of spellbook definitions is present.

  This is called "StandardBookOfSpells".

  Returns true if present, otherwise false.
  """
  def contains_default_spellbook() do
    if File.exists?(@default_spellbook) do
      true
    else
      false
    end
  end

  @doc """
  Helper utility function to clone the default spellbook, or repository
  of spell definitions.

  The default repository is controlled by an environment variable, if not present,
  Spellbook.Environment defines the default that points to official github repository.
  """
  def clone_default_spellbook() do
    create_stacks()
    IO.puts("Cloning #{@default_spellbook_repo} into #{@stacks}")
    Spellbook.GitOps.clone(@default_spellbook_repo, @stacks)
  end

  @doc """
  Helper function that will update the default repository if present.
  """
  def update_default_spellbook() do
    if File.exists?(@default_spellbook) do
      Spellbook.GitOps.fetch_and_pull(@default_spellbook)
    end
  end

  def search_stacks_get_first(search_term) do
    search_stacks(search_term)
    |> List.first()
  end

  @doc """
  Entry function for a recursive search the stack to find a spell based on a given search term.

  Returns a list of files with their full path.
  """
  def search_stacks(search_term) do
    do_search(@stacks, search_term)
    |> List.flatten()
    |> Enum.reject(fn path -> path == nil end)
  end

  defp do_search(dir, search_term) do
    dir
    |> File.ls!()
    |> Enum.reject(fn file -> file == ".git" end)
    |> Enum.map(fn file ->
      path = Path.join(dir, file)

      cond do
        File.dir?(path) ->
          do_search(path, search_term)

        Spellbook.Utils.is_match?(path, search_term) ->
          path

        true ->
          nil
      end
    end)
  end
end
