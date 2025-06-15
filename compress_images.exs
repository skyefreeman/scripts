#!/usr/bin/env elixir

# Mix.install([])
# Requires ImageMagick (or GraphicsMagick) to be installed on your system.
# On macOS: brew install imagemagick
# On Ubuntu/Debian: sudo apt-get install imagemagick

# Check for ImageMagick's 'convert' command availability
case System.cmd("which", ["convert"], stderr_to_stdout: true) do
  {_output, 0} -> :ok
  {output, _} ->
    IO.puts("Error: 'convert' command (ImageMagick) not found in your PATH.")
    IO.puts("Please install ImageMagick to use this script.")
    IO.puts("For example (macOS):         brew install imagemagick")
    IO.puts("For example (Ubuntu/Debian): sudo apt-get install imagemagick")
    IO.puts("Full error output:\n#{output}")
    System.halt(1)
end


defmodule Script do

  # --- Configuration ---

  def max_file_size_bytes() do
    800 * 1024 # 800 KB
  end

  defp supported_extensions() do
    [".jpeg", ".jpg", ".png"]
  end

  # --- Helper Functions ---

  defp get_extension(path) do
    path
    |> Path.extname()
    |> String.downcase()
  end

  defp is_supported_image?(path) do
    get_extension(path) in supported_extensions()
  end

  defp is_larger_than_limit?(path, limit_bytes) do
    case File.stat(path) do
      {:ok, %File.Stat{size: size}} when size > limit_bytes -> true
      _ -> false
    end
  end

  defp shrink_image(original_path, target_size_bytes) do
    base = String.split(original_path, ".") |> List.first
    ext = get_extension(original_path)
    # Create a new file with an _optimized suffix to avoid overwriting originals
    optimized_path = base <> "_optimized" <> ext

    IO.puts("  Attempting to shrink '#{original_path}' to ~#{(target_size_bytes / 1024) |> round} KB...")

    command = "convert"
    args =
      case ext do
        ".jpeg" -> [
          original_path,
          "-define", "jpeg:extent=#{target_size_bytes / 1024}kb",
          optimized_path
        ]
        ".jpg" -> [
          original_path,
          "-define", "jpeg:extent=#{target_size_bytes / 1024}kb",
          optimized_path
        ]
        ".png" -> [
          # For PNGs, directly targeting a precise file size is harder with 'convert'
          # without potentially changing to a lossy format or using iterative resizing.
          # This uses quality reduction and a slight resize as heuristics.
          original_path,
          "-quality", "85%",
          "-resize", "90%",
          optimized_path
        ]
        _ ->
          IO.puts("Unsupported image type for shrinking: #{original_path} (this should not happen based on filtering)")
          nil # Indicate no command
      end

    if args do
      case System.cmd(command, args, stderr_to_stdout: true) do
        {_output, 0} ->
          IO.puts("  Optimized image created: '#{optimized_path}'")
          case File.stat(optimized_path) do
            {:ok, %File.Stat{size: new_size}} ->
              IO.puts("  New size: #{(new_size / 1024) |> Float.round(2)} KB")
              if new_size > target_size_bytes && get_extension(original_path) == ".png" do
                IO.puts("  Note: PNG might not reach exact target size due to lossless nature. Further reduction might require more aggressive resizing or conversion to JPEG.")
              end
            _ ->
              IO.puts("  Warning: Could not get stats for optimized file: '#{optimized_path}'")
          end
          {:ok, optimized_path}
        {output, exit_code} ->
          IO.puts("  Error reducing '#{original_path}'. Exit code: #{exit_code}. Output:\n#{output}")
          {:error, :image_magick_failure}
      end
    else
      {:error, :unsupported_format}
    end
  end

  # --- Recursive Directory Traversal ---
  def process_directory(current_path) do
    case File.ls(current_path) do
      {:ok, entries} ->
        Enum.each(entries, fn entry ->
          full_path = Path.join(current_path, entry)

          # Skip '.' and '..'
          case entry do
            "." -> :ok
            ".." -> :ok
            _ ->
              case File.stat(full_path) do
                {:ok, %File.Stat{type: :regular}} -> # It's a file
                if is_supported_image?(full_path) do
                  if is_larger_than_limit?(full_path, max_file_size_bytes()) do
                    IO.puts("\nFound large image: '#{full_path}'")
                    shrink_image(full_path, max_file_size_bytes())
                  end
                end
                {:ok, %File.Stat{type: :directory}} -> # It's a directory
                  process_directory(full_path) # Recurse
                {:error, reason} ->
                  IO.puts("Error statting '#{full_path}': #{reason}")
              end
          end
        end)
      {:error, reason} ->
        # Handle cases where directory might not be readable
        IO.puts("Error listing directory '#{current_path}': #{reason}")
    end
  end
end

# --- Main Script Logic ---

IO.puts("Starting image processing from #{File.cwd!()}")
IO.puts("Looking for images larger than #{(Script.max_file_size_bytes() / 1024) |> round} KB...")
IO.puts("Optimized files will have '_optimized' suffix (e.g., image_optimized.jpg).")

Script.process_directory(File.cwd!())

IO.puts("\nImage processing complete.")
