defmodule Spellbook.Stacks do
  @stacks Spellbook.Environment.the_stacks()

  def create_stacks() do
    if File.exists?(@stacks) == false do
      Spellbook.Utils.create_dir(@stacks)
    end
  end

  def contains_spellbooks() do
    create_stacks()

    if File.exists?(@stacks) do
      count =
        File.ls!(@stacks)
        |> Enum.count()

      dbg(count)

      if count > 0 do
        true
      else
        false
      end
    end
  end
end
