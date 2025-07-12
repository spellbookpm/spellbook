defmodule Spellbook.GitOps do

  def clone(url, target) do
    {:ok, git_path} = Spellbook.Utils.get_executable_path("git")
    dbg(git_path)

    case System.cmd(git_path, ["clone", url], cd: target) do
      {"", 0} -> :ok
      {message, errorCode} -> 
        IO.puts("#{errorCode}: #{message}")
        :error
      {[messages], errorCode} ->
        :error
    end
  end

end
