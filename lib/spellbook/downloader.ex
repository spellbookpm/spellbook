defmodule Spellbook.Downloader do

  def download(url, dst_path) do
    try do
      Req.get!(url, into: File.stream!(dst_path, [:write, :binary]))
      {:ok, dst_path}
    rescue
      e -> {:error, Exception.message(e)}
    end
  end

end
