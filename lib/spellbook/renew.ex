defmodule Spellbook.Renew do
  @behaviour Spellbook.Action

  alias Spellbook.Stacks

  def perform(_args) do
    if Stacks.contains_default_spellbook() do
      Stacks.update_default_spellbook()
    else
      Stacks.clone_default_spellbook()
    end

  end
end
