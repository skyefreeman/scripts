#!/usr/bin/env elixir

defmodule PlaylistDownloader do
  @moduledoc """
  A module to download a full YouTube playlist concurrently using yt-dlp.
  """

  def run(playlist_url, dir) do
    # Get the list of video URLs from the playlist
    video_urls =
      System.cmd("/Users/skye/scripts/youtube-playlist-extractor.sh", [playlist_url])
      |> elem(0)
      |> String.split("\n")
      |> Enum.filter(fn s -> s != "" end)
    
    # Use Task to download videos concurrently
    tasks =
      Enum.map(video_urls, fn url ->
        Task.async(fn ->
          IO.puts("[skye] Starting download: #{url}")
          System.cmd("/Users/skye/scripts/download-video.sh", [url, dir])
        end)
      end)
    
    Task.await_many(tasks, :infinity)
    IO.puts("[skye] All videos downloaded to #{dir}")
  end
end

if length(System.argv()) != 2 do
  IO.puts("[skye] Usage: elixir playlist_downloader.exs <playlist-url> <output-dir>")
else
  playlist_url = Enum.at(System.argv(), 0)
  output_dir = Enum.at(System.argv(), 1)
  PlaylistDownloader.run(playlist_url, output_dir)
end
