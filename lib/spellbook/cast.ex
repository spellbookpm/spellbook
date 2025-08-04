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
  alias Spellbook.DependencyTree
  alias Spellbook.Environment
  alias Spellbook.Linker
  alias Spellbook.Spells
  alias Spellbook.TopologicalSort
  alias Spellbook.Utils

  @doc """
   Function called by the cli to handle casting of a spell, or installing a requested package. 
  """
  def perform(args) do
    with dependency_list <- get_install_order(args),
         installed_spells <- get_installed_spells(),
         final_list <- remove_installed_spells(dependency_list, installed_spells),
         :ok <- install_dependencies(final_list),
         :ok <- install_spell(args) do
      IO.puts("Casted #{args} sucessfully")
      :ok
    else
      _ ->
        :error
    end
  end

  defp get_install_order(spell_name) do
    with {_memo, tree} <- DependencyTree.build(spell_name),
         {order, _cache} <- TopologicalSort.sort(tree) do
      Enum.reverse(order)
    else
      _ ->
        {:error, "An error occured with gathering dependencies."}
    end
  end

  defp install_dependencies(list) do
    case Enum.reduce_while(list, :ok, fn spell, _acc ->
           case install_spell(spell) do
             :ok ->
               {:cont, :ok}

             :error ->
               {:halt, {:error, "An error occured installing #{spell}"}}

             {:error, message} ->
               {:halt, {:error, message}}

             _ ->
               {:halt, {:error, "An unknown error occured while installing #{spell}"}}
           end
         end) do
      :ok ->
        :ok

      :error ->
        {:error, "An error occured installing dependencies"}

      {:error, message} ->
        {:error, message}

      _ ->
        {:error, "An unknown error occured installing dependencies"}
    end
  end

  defp install_spell(spell_name) do
    IO.puts("Warming up to perform cast for spell #{spell_name}")

    with false <- Spells.does_spell_exist(spell_name),
         {:ok, module} <- Builder.get_spell_specification(spell_name),
         {:ok, build_path} <- Builder.setup_build_dir(module.name(), module.version()),
         {:ok, sources_path} <- Builder.get_build_sources(module.source(), build_path),
         sources_path <- Path.join(sources_path, module.name() <> "-" <> module.version()),
         install_prefix <- Utils.compute_install_prefix(module.name(), module.version()),
         :ok <- Builder.run_install(module, %{install_prefix: install_prefix, cwd: sources_path}) do
      Linker.link_spell(module.name(), module.version())
      :ok
    else
      true ->
        IO.puts("Spell #{spell_name} has already been casted.")
        :error

      {:error, message} ->
        IO.puts("Error: #{message}")
        :error

      _ ->
        IO.puts("An unknown error occured")
        :error
    end
  end

  defp get_installed_spells() do
    Environment.spells_dir()
    |> File.ls!()
    |> List.flatten()
  end

  defp remove_installed_spells(dep_list, installed_list) do
    dep_list
    |> Enum.reject(fn entry -> entry in installed_list end)
  end
end
