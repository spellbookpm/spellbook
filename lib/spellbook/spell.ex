defmodule Spellbook.Spell do
  @callback name :: String.t()
  @callback version :: String.t()
  @callback homepage :: String.t()
  @callback license :: String.t()
  @callback type :: String.t()
  @callback deps :: [String.t()]
  @callback checksum :: String.t()
  @callback source :: String.t()
  @callback install(args :: map()) :: any()
end

