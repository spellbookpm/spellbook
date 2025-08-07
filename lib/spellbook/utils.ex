defmodule Spellbook.Utils do
  @moduledoc """
  Module containing a collection of utility functions.
  """

  @doc """
  Attempts to get a path for a temporary directly for the system the code is
  running on.
  """
  def get_tmp_dir() do
    try do
      tmp_dir = System.tmp_dir!()
      {:ok, tmp_dir}
    rescue
      RuntimeError -> {:error, "Could not create temporary directory for build"}
    end
  end

  @doc """
  Attempts to create a directory given the full path to the directory.
  """
  def create_dir(path) do
    try do
      File.mkdir_p!(path)
      {:ok, path}
    rescue
      File.Error -> {:error, "Could not create directory."}
    end
  end

  @doc """
  Attempts to create a symlink given a full path to a file as a source
  and the full path and filename as the target
  """
  def create_symlink(source, target) do
    IO.puts("Creating symlink #{source} -> #{target}")
    File.ln_s!(source, target)
  end

  @doc """
  Helper utility for downloading a file.

  Requires a source, which is a url to a resource. 
  Requires a target_dir, as a target directory for where the source should be downloaded to.

  If sucessful, return a tuple with ok and the path to the now downloaded source.
  Otherwise return an a tuple with an error and a message.
  """
  # TODO: refactor into Spellbook.Downloader
  def download_source(source, target_dir) do
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

    case Spellbook.Downloader.download(source, dst_file) do
      {:ok, path} ->
        IO.puts("Download complete")
        {:ok, path}

      {:error, message} ->
        IO.puts("Error: #{message}")
        System.halt(1)
    end
  end

  @doc ~S"""
  Computes the folder structure for a the install prefix

  Requires a module_name, being the name of the pacakge/spell.
  Requires a version, the version number for the package/spell.

  Returns a string.

  ## Examples
    iex> Spellbook.Utils.compute_install_prefix("htop", "3.4.1")
    "/opt/spellbook/Spells/htop/3.4.1"
  """
  def compute_install_prefix(module_name, module_version) do
    Spellbook.Environment.spells_dir() <> "/#{module_name}/#{module_version}"
  end

  @doc """
  Attempts to find an executable on the system it is running on.

  Requires a name, this is the executable name.

  On success, return a tuple with ok and the pull path to the binary.
  Otherwise, return a tuple with an error and a message.

  ## Examples
    iex> Spellbook.Utils.get_executable_path("ls")
    {:ok, "/bin/ls"} 
  """
  def get_executable_path(name) do
    case System.find_executable(name) do
      path ->
        {:ok, path}

      nil ->
        {:error, "Does not exist on system..."}
    end
  end

  @doc """
  Attempts to untar a tarball using the tar executable on the local system.

  Requires a program, this is the tar program.
  Requires a path, path where the tarball lives.
  Requires a tarball, this is the name of the tar compressed file.

  On success return ok with the path to the folder of containing the compressed and uncompressed tar file.
  Otherwise, return an error and a message.
  """
  def untar(program, path, tarball) do
    # dbg(path)
    # dbg(tarball)
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

  @doc """
  Attempts to remove a file.

  Requires a file, which is the file and it's full path.
  """
  def remove_file(file) do
    if File.exists?(file) do
      IO.puts("Removing file: #{file}")
      File.rm(file)
    end
  end

  @doc """
  Attempts to remove files from a list of files.

  Requires a list of pully pathed files.
  """
  def remove_files(files) when is_list(files) do
    files
    |> Enum.each(fn entry ->
      if File.exists?(entry) do
        IO.puts("Removing file: #{entry}")
        File.rm(entry)
      end
    end)
  end

  @doc """
  Attempts to perform a resursive and force remove.

  This should be used for removing directories and it's children.

  Requires a path, path to the directory/file to be removed.
  """
  def rm_rf(path) do
    IO.puts("Removing directly #{path}")
    File.rm_rf(path)
  end
  
  @doc """
  Present a prompt for the user to answer
  """
  def yes_no_prompt(prompt) do
    case IO.getn(prompt <> " [y/n] ", 1) do
      "y" -> :yes
      "n" -> :no
      _ -> :unsupported_input
    end
  end
end
