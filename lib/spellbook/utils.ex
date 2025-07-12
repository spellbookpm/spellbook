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

  def download_source(source, target_dir, _target_name) do
    # file_name = Path.basename(source)
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
end
