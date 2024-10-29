#!/usr/bin/env elixir

# Mix.install([])

defmodule CLI do
  def merge_directories(source, destination) do
    # rsync -av
# ~/Downloads/Timelord-4/FramelordSnapshotTests/FailureDiffs/TLAcceptInviteSnapshotTestCase/
# ~/dev/pushd-apps/Timelord/FramelordSnapshotTests/Snapshot\ Tests/__Snapshots__/TLAcceptInviteSnapshotTestCase/

    System.cmd("rsync", ["-av", source, destination]) |> IO.inspect
  end
  
  def list_files(path) do
    {:ok, entries} = File.ls(path)
    
    entries
    |> Enum.each(fn entry ->
      full_path = Path.join(path, entry)
      case File.stat(full_path) do
	{:ok, %File.Stat{type: :directory}} ->
          IO.puts("Directory: #{entry}")
	{:ok, %File.Stat{type: :regular}} ->
          IO.puts("File: #{entry}")
	_error ->
          IO.puts("Unable to read: #{entry}")
      end
    end)
  end
end

# ~/Downloads/Timelord-4/FramelordSnapshotTests/FailureDiffs/TLAcceptInviteSnapshotTestCase/
# ~/dev/pushd-apps/Timelord/FramelordSnapshotTests/Snapshot\ Tests/__Snapshots__/TLAcceptInviteSnapshotTestCase/


CLI.merge_directories(
  "/Users/skyefreeman/Downloads/Timelord-4/FramelordSnapshotTests/FailureDiffs/",
  "/Users/skyefreeman/dev/pushd-apps/Timelord/FramelordSnapshotTests/Snapshot\ Tests/__Snapshots__"
)

