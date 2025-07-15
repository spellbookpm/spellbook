defmodule Spellbook.Cast do
  @moduledoc """
  The module that is called in to for the cast subcommand. The main bit of code is the perform function
  which, in this case, handles the process of installing a specified 'spell' should it exist.

  Currently, this is done by pulling the source code for the project based on the spell specification
  and then setting up a temporary directory to build in, followed by building and installing into the
  appropriate paths.
  """

  @behaviour Spellbook.Action

  alias Spellbook.Stacks

  # TODO: refactor to use pipes

  @doc """
   Function called by the cli to handle casting of a spell, or installing a requested package. 
  """
  def perform(args) do
    IO.puts("Looking up spell #{args}")

    spec =
      case Stacks.search_stacks(args) do
        [] ->
          IO.puts("Could not find #{args}")
          :error

        [first | _rest] ->
          first
      end

    dbg(spec)

    IO.puts("Warming up to perform cast...")
    IO.puts("Casting #{args}")

    module =
      case load_file(spec) do
        {:ok, module} -> module
        {:error, message} -> IO.puts("Error: #{message}")
      end

    tmp_dir =
      case Spellbook.Utils.get_tmp_dir() do
        {:ok, tmp_dir} ->
          tmp_dir

        {:error, message} ->
          IO.puts("Error: #{message}")
          {:error}
      end

    pkg_name = "#{module.name()}-#{module.version()}"

    build_dir = "#{tmp_dir}#{module.name()}-#{module.version()}"
    IO.puts("Build directory: #{build_dir}")

    build_dir =
      case Spellbook.Utils.create_dir(build_dir) do
        {:ok, path} ->
          path

        {:error, message} ->
          IO.puts("Error creating build directory: #{message}")
          System.halt(1)
      end

    # download and extract
    tar_executable =
      case Spellbook.Utils.get_executable_path("tar") do
        {:ok, tar_path} ->
          tar_path

        {:error, message} ->
          IO.puts("Error: #{message}")
          System.halt(1)
      end

    {result, path} = Spellbook.Utils.download_source(module.source(), build_dir, pkg_name)
    IO.puts("Extracing #{path}....")

    path =
      case Spellbook.Utils.untar(tar_executable, build_dir, Path.basename(path)) do
        {:ok, path} ->
          path

        {:error, message} ->
          IO.puts("Error: #{message}")
          System.halt(1)
      end

    IO.puts("Extraction complete: #{path}")

    install_prefix = Spellbook.Utils.compute_install_prefix(module.name(), module.version())

    # run build commands
    case module.install(%{
           prefix: install_prefix,
           cwd: "#{path}/#{module.name()}-#{module.version()}"
         }) do
      :ok ->
        IO.puts("Successfully installed #{module.name()}")
    end

    IO.puts("Linking...")
    Spellbook.Linker.link_spell(module.name(), module.version())

    # clean up

    IO.puts("Done casting...")
  end

  @doc """
  Helper function to compile and load a path'd exs file. In this case, it is used to load
  the spell specification from the 'ports tree' repository on the disk.
  """
  defp load_file(args) do
    case Code.compile_file(args) do
      [{module, _binary}] ->
        {:ok, module}

      [] ->
        {:error, "Not found."}

      _ ->
        {:error, "Unknown error."}
    end
  end
end
