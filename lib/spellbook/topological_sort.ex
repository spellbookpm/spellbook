defmodule Spellbook.TopologicalSort do
  @moduledoc """
  Module for code related to performing the topological sort 
  of the dependency tree.
  """

  @doc """
  Apply a topological sort to a graph
  """
  def sort(tree) do
    do_sort(tree, [], MapSet.new())
  end

  defp do_sort([], acc, seen), do: {acc, seen}

  defp do_sort([{spell, children} | rest], acc, seen) do
    {acc, seen} = do_sort(children, acc, seen)

    if MapSet.member?(seen, spell) do
      do_sort(rest, acc, seen)
    else
      do_sort(rest, [spell | acc], MapSet.put(seen, spell))
    end
  end
end
