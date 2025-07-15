defmodule Spellbook.Downloader do
  @moduledoc """
  Module for functionality related to downloading.
  """

  @doc """
  Downloads files from a given URL to the specified path.
  """
  def download(url, dst_path) do
    try do
      Req.get!(url, into: File.stream!(dst_path, [:write, :binary]))
      {:ok, dst_path}
    rescue
      e -> {:error, Exception.message(e)}
    end
  end
end
