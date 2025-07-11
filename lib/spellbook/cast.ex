defmodule Spellbook.Cast do
  @behaviour Spellbook.Action

  # TODO: refactor to use pipes

  def perform(args) do
    IO.puts("Warming up to perform cast...")
    IO.puts("Casting #{args}")
     module = case load_file(args) do
      {:ok, module} -> module
      {:error, message} -> IO.puts("Error: #{message}")
    end
    
    tmp_dir = case Spellbook.Utils.get_tmp_dir() do
      {:ok, tmp_dir} -> 
        tmp_dir
      {:error, message} ->
        IO.puts("Error: #{message}")
        {:error}
    end
 
    pkg_name = "#{module.name()}-#{module.version()}"

    build_dir = "#{tmp_dir}#{module.name()}-#{module.version()}"
    IO.puts("Build directory: #{build_dir}")

    build_dir = case Spellbook.Utils.create_dir(build_dir) do
      {:ok, path} -> path
      {:error, message} ->
        IO.puts("Error creating build directory: #{message}")
        System.halt(1)  
    end

    IO.puts("Now on to something else")

    # download and extract
    tar_executable = case Spellbook.Utils.get_executable_path("tar") do
      {:ok, tar_path} -> tar_path
      {:error, message} -> 
        IO.puts("Error: #{message}")
        System.halt(1)
    end

    { result, path } = Spellbook.Utils.download_source(module.source(), build_dir, pkg_name)
    IO.puts("Extracing #{path}....")

    path = case Spellbook.Utils.untar(tar_executable, build_dir, Path.basename(path)) do
      {:ok, path} -> path
      {:error, message} ->
        IO.puts("Error: #{message}")
        System.halt(1)
    end

    IO.puts("Extraction complete: #{path}")

    install_prefix = Spellbook.Utils.compute_install_prefix(module.name(), module.version())
    
    # run build commands
    case module.install(%{prefix: install_prefix, cwd: "#{path}/#{module.name()}-#{module.version()}"}) do
      :ok ->
        IO.puts("Successfully installed #{module.name()}")
    end

    # clean up

    IO.puts("Done casting...")
  end

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
