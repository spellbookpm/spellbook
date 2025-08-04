defmodule Spellbook.DependencyTree do
  @moduledoc """
  Module for resolving and constructing dependency trees for spells.  
  """

  alias Spellbook.Stacks

  def build(spell_name) do
    build(spell_name, %{})
  end

  defp build(spell_name, memo) do
    if Map.has_key?(memo, spell_name) do
      {memo, Map.get(memo, spell_name)}
    else
      case load_deps(spell_name) do
        {:ok, deps} ->
          {memo, resolved_deps} =
            Enum.reduce(deps, {memo, []}, fn dep, {acc_memo, acc_deps} ->
              {new_memo, subtree} = build(dep, acc_memo)
              {new_memo, [{dep, subtree} | acc_deps]}
            end)

          final_memo = Map.put(memo, spell_name, resolved_deps)
          {final_memo, resolved_deps}

        {:error, reason} ->
          IO.warn("Failed to load spell #{spell_name}: #{reason}")

          # :end ->
          #   dbg("Found the end of a branch")
      end
    end
  end

  defp load_deps(spell_name) do
    with spell_path <- Stacks.search_stacks_get_first(spell_name),
         true <- File.exists?(spell_path),
         [{module, _}] <- Code.compile_file(spell_path),
         deps <- module.deps() do
      {:ok, deps}
    else
      _ ->
        {:error, "An error occured with loading dependencies"}
    end
  end
end
