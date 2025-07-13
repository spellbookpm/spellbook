defmodule Spellbook.GitOps do
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

  def fetch_and_pull(cwd) do
    {ok, git_path} = Spellbook.Utils.get_executable_path("git")

    case System.cmd(git_path, ["fetch", "--all"], cd: cwd) do
      {_message, 0} ->
        :ok

      {message, error_code} ->
        IO.puts("#{error_code}: #{message}")
        :error

      {[messages], error_code} ->
        :error
    end

    case System.cmd(git_path, ["pull"], cd: cwd) do
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
