
defmodule Spellbook.Grimoire do
  @behaviour Spellbook.Action

  def perform(_args) do
    Spellbook.Environment.spells_dir()
      |> File.ls!()
      |> List.flatten()
      |> Enum.each(fn entry -> IO.puts(entry) end)
  end
end
