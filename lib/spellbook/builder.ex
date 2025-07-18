defmodule Spellbook.Builder do
  @moduledoc """
  Module for code related to the building and build environment of packages.
  """

  alias Spellbook.Environment
  alias Spellbook.Stacks
  alias Spellbook.Utils

  @doc """
  Get and load the spell specification for a given spell from the stacks.

  Requires a spell_name, the name of the spell

  On success returns ok with the compiled file module
  On failure returns error with a message
  """
  def get_spell_specification(spell_name) do
    with spell_spec <- Stacks.search_stacks_get_first(spell_name),
         [{module, _binary}] <- Code.load_file(spell_spec) do
      {:ok, module}
    else
      nil -> {:error, "Could not locate a spell"}
      _ -> {:error, "An error occured in getting spell specification"}
    end
  end

  @doc ~S"""
  Set up  the build directory

  Requires a spell, this is the name of the spell
  Requires a version, this is the version number for the spell

  Returns on success ok with the build directory
  Returns on failure error with a message
  """
  def setup_build_dir(spell, version) do
    with {:ok, tmp_dir} <- Utils.get_tmp_dir(),
         build_dir <- Path.join(tmp_dir, "#{spell}-#{version}"),
         {:ok, path} <- Utils.create_dir(build_dir) do
      {:ok, path}
    else
      _ -> {:error, "Error occued with setting up build directory"}
    end
  end

  @doc """
  Get the compressed build sources and uncompress them.

  Requires the source, which is the url in the spell specification
  Requires a target, the target directory for it download and unpack the compressed sourced

  On success, return ok with the path to the untared sources
  On error, return an error with a message
  """
  def get_build_sources(source, target) do
    with {:ok, tar_path} <- Utils.get_executable_path("tar"),
         {:ok, download_path} <- Utils.download_source(source, target),
         {:ok, untar_path} <- Utils.untar(tar_path, target, Path.basename(download_path)) do
      {:ok, untar_path}
    else
      {:error, message} ->
        {:error, message}

      _ ->
        {:error, "An error occured in getting build sources"}
    end
  end

  @doc """
  Run the install function in a spell specification.

  Requires the loaded compile file for the module
  Requires args as a map of arguments to use for the build process

  On success, returns ok
  On failure, returns an error with a message
  """
  def run_install(module, args) do
    case module.install(%{
           prefix: args.install_prefix,
           cwd: args.cwd
         }) do
      :ok ->
        :ok

      :error ->
        {:error, "Failed to build"}

      _ ->
        {:error, "Unknown error on building"}
    end
  end
end
