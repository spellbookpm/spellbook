defmodule Spellbook.Downloader do
  @moduledoc """
  Module for functionality related to downloading.
  """

  @doc """
  Downloads files from a given URL to the specified path.

  Requires a url, this is the url that the resource resides at.
  Requires a dest_path, path to the destination to download the resource into.

  On success, return ok with the path to the downloaded resource's parent directory.
  Otherwise, return an error.
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
