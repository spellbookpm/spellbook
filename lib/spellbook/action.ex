defmodule Spellbook.Action do
  @callback perform(any()) :: any()
end
