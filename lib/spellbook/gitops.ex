defmodule Spellbook.GitOps do

  def clone(url, target) do
    # git:clone(url)
    {:ok, git_path} = Spellbook.Utils.get_executable_path("git")
    dbg(git_path)

    result = System.cmd(git_path, ["clone", url], cd: target)
    dbg(result)
    :ok
  end

end
