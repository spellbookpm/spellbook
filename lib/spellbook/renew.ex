defmodule Spellbook.Renew do
  @moduledoc """
  Module for the command line to call into for handling the renew subcommand.
  """

  @behaviour Spellbook.Action

  alias Spellbook.Stacks

  @doc """
  Function called into my the CLI handler to handle the renew subcomment.

  Checks if the repo for the stack is cloned, if it is, perform a fetch and update.
  Otherwise clone the repository into the `$PREFIX/TheStacks` location.
  """
  def perform(_args) do
    if Stacks.contains_default_spellbook() do
      Stacks.update_default_spellbook()
    else
      Stacks.clone_default_spellbook()
    end
  end
end
