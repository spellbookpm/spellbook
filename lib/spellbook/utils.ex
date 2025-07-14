defmodule Spellbook.Utils do
  def get_tmp_dir() do
    try do
      tmp_dir = System.tmp_dir!()
      {:ok, tmp_dir}
    rescue
      RuntimeError -> {:error, "Could not create temporary directory for build"}
    end
  end

  def create_dir(path) do
    try do
      File.mkdir_p!(path)
      {:ok, path}
    rescue
      File.Error -> {:error, "Could not create directory."}
    end
  end

  def create_symlink(source, target) do
    IO.puts("Creating symlink #{source} -> #{target}")
    File.ln_s!(source, target)
  end

  # TODO: refactor into Spellbook.Downloader
  def download_source(source, target_dir, _target_name) do
    file_name = List.last(String.split(source, "/"))

    dst_path =
      case create_dir(target_dir) do
        {:ok, path} ->
          path

        {:error, message} ->
          IO.puts("Error: #{message}")
          System.halt(1)
      end

    dst_file = Path.join(dst_path, file_name)

    IO.puts("Downloading #{source} to #{dst_file}")

    path =
      case Spellbook.Downloader.download(source, dst_file) do
        {:ok, path} ->
          IO.puts("Download complete")
          {:ok, path}

        {:error, message} ->
          IO.puts("Error: #{message}")
          System.halt(1)
      end
  end

  def extract_tar_gz(source, target) do
    source_charlist = String.to_charlist(source)
    target_charlist = String.to_charlist(target)

    case :erl_tar.extract(source_charlist, [:compressed, {:cwd, target_charlist}]) do
      :ok ->
        {:ok, target}

      {:error, reason} ->
        {:error, "Failed to unpack tar.gz: #{inspect(reason)}"}
    end
  end

  @doc ~S"""
  Computes the folder structure for a the install prefix
  ## Examples
    iex> Spellbook.Utils.compute_install_prefix("htop", "3.4.1")
    "/opt/spellbook/Spells/htop/3.4.1"
  """
  def compute_install_prefix(module_name, module_version) do
    Spellbook.Environment.spells_dir() <> "/#{module_name}/#{module_version}"
  end

  def get_executable_path(name) do
    case System.find_executable(name) do
      path ->
        {:ok, path}

      nil ->
        {:error, "Does not exist on system..."}
    end
  end

  def untar(program, path, tarball) do
    case System.cmd(program, ["xf", tarball], cd: path) do
      {_collectable, 0} -> {:ok, path}
      {_collectable, 1} -> {:error, "Could not untar file..."}
    end
  end

  @doc ~S"""
  Checks to see if there is an exact match between two strings

  ## Examples
    iex> Spellbook.Utils.is_match?("one", "one")
    true

    iex> Spellbook.Utils.is_match?("one", "two")
    false
  """
  def is_match?(file, search_term) do
    spec = Path.basename(file) |> Path.rootname(".exs")
    String.jaro_distance(spec, search_term) == 1.0
  end

  def remove_file(file) do
    if File.exists?(file) do
      Io.puts("Removing file: #{file}")
      File.rm(file)
    end
  end

  def remove_files(files) when is_list(files) do
    files
    |> Enum.each(fn entry ->
      if File.exists?(entry) do
        IO.puts("Removing file: #{entry}")
        File.rm(entry)
      end
    end)
  end

  def rm_rf(path) do
    IO.puts("Removing directly #{path}")
    File.rm_rf(path)
  end
end
