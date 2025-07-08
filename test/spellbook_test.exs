defmodule SpellbookTest do
  use ExUnit.Case
  doctest Spellbook

  test "greets the world" do
    assert Spellbook.hello() == :world
  end
end
