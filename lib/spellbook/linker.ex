defmodule Spellbook.Linker do
  @bin Path.join(Spellbook.Environment.prefix(), "bin")
  @share Path.join(Spellbook.Environment.prefix(), "share")
  @lib Path.join(Spellbook.Environment.prefix(), "lib")

  def link_spell(name, version) do
    base =
      Spellbook.Environment.spells_dir()
      |> Path.join(name)
      |> Path.join(version)

    dbg(base)
    link_binary(Path.join(base, "bin"))
    link_share(Path.join(base, "share"))
    link_lib(Path.join(base, "lib"))
  end

  def link_binary(bin_path) do
    create_bin_dir()

    if File.exists?(bin_path) do
      File.ls!(bin_path)
      |> Enum.each(fn file ->
        source = Path.join(bin_path, file)
        target = Path.join(@bin, file)
        Spellbook.Utils.create_symlink(source, target)
      end)
    end
  end

  def link_share(share_path) do
    create_share_dir()

    if File.dir?(share_path) do
      link_recursively(share_path, @share)
    end
  end

  def link_lib(lib_path) do
    create_lib_dir()

    if File.exists?(lib_path) do
      File.ls!(lib_path)
      |> Enum.each(fn file ->
        source = Path.join(lib_path, file)
        target = Path.join(@lib, file)
        Spellbook.Utils.create_symlink(source, target)
      end)
    end
  end

  defp link_recursively(source_dir, target_dir) do
    File.ls!(source_dir)
    |> Enum.each(fn file ->
      source = Path.join(source_dir, file)
      target = Path.join(target_dir, file)

      cond do
        File.dir?(source) ->
          Spellbook.Utils.create_dir(target)
          link_recursively(source, target)

        File.regular?(source) ->
          Spellbook.Utils.create_symlink(source, target)

        true ->
          :noop
      end
    end)
  end

  defp create_bin_dir() do
    if File.exists?(@bin) == false do
      IO.puts("Creating #{@bin}...")
      Spellbook.Utils.create_dir(@bin)
    end
  end

  defp create_share_dir() do
    if File.exists?(@share) == false do
      IO.puts("Creating #{@share}...")
      Spellbook.Utils.create_dir(@share)
    end
  end

  defp create_lib_dir() do
    if File.exists?(@lib) == false do
      IO.puts("Creating #{@lib}...")
      Spellbook.Utils.create_dir(@lib)
    end
  end
end
