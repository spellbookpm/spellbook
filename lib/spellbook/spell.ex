defmodule Spellbook.Spell do
  @moduledoc """
  This module is the bheavior definition for Spells. All spell defintions should conform
  to this as the behaviour and implement these callbacks.
  """

  @callback name :: String.t()
  @callback version :: String.t()
  @callback homepage :: String.t()
  @callback license :: String.t()
  @callback type :: String.t()
  @callback deps :: [String.t()]
  @callback checksum :: String.t()
  @callback source :: String.t()
  @callback description :: String.t()
  @callback install(args :: map()) :: any()
end
