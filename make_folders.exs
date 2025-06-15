#!/usr/bin/env elixir

# Mix.install([])

args = System.argv()

case args do
  [new_folder_name] ->
    current_dir = File.cwd!()
    IO.puts("Iterating through subdirectories in '#{current_dir}' and creating '#{new_folder_name}'...")

    case File.ls(current_dir) do
      {:ok, entries} ->
        directories = Enum.filter(entries, fn entry ->
        full_path = Path.join(current_dir, entry)
        File.dir?(full_path)
      end)
      |> Enum.reject(fn entry -> entry == "." || entry == ".." end)

        Enum.each(directories, fn dir_name ->
          target_path = Path.join([current_dir, dir_name, new_folder_name])
          IO.puts("  Creating: '#{target_path}'")

          case File.mkdir_p(target_path) do
            :ok ->
              :ok
            {:error, reason} ->
              IO.puts("Error: Could not create #{target_path}. Reason: #{reason}")
          end
        end)

        IO.puts("Process complete.")

      {:error, reason} ->
        IO.puts("Error listing directory '#{current_dir}'. Reason: #{reason}")
        System.halt(1)
    end

  _ ->
    IO.puts("Usage: elixir #{__ENV__.file} <new_folder_name>")
    IO.puts("Example: elixir #{__ENV__.file} backups")
    System.halt(1)
end
