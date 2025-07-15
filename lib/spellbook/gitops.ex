defmodule Spellbook.GitOps do
  @moduledoc """
  This module handles functionality related to git. Functions handle various git operations.
  """

  @doc """
  Clone a given repository at the url to a target directory.

  Utilized a command to git installed on the system.
  """
  def clone(url, target) do
    {:ok, git_path} = Spellbook.Utils.get_executable_path("git")
    dbg(git_path)

    case System.cmd(git_path, ["clone", url], cd: target) do
      {_message, 0} ->
        :ok

      {message, error_code} ->
        IO.puts("#{error_code}: #{message}")
        :error

      {[messages], error_code} ->
        :error
    end
  end

  @doc """
  Fetches and pulls the checked out branch of a given git repo based on the repo's
  current working directory.

  Utilizes the system's installed git.
  """
  def fetch_and_pull(cwd) do
    {ok, git_path} = Spellbook.Utils.get_executable_path("git")

    case System.cmd(git_path, ["fetch", "--all"], cd: cwd, into: IO.stream()) do
      {_message, 0} ->
        :ok

      {message, error_code} ->
        IO.puts("#{error_code}: #{message}")
        :error

      {[messages], error_code} ->
        :error
    end

    case System.cmd(git_path, ["pull"], cd: cwd, into: IO.stream()) do
      {_message, 0} ->
        :ok

      {message, error_code} ->
        IO.puts("#{error_code}: #{message}")
        :error

      {[messages], error_code} ->
        :error
    end
  end
end
