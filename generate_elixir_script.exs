#!/usr/bin/env elixir

# Mix.install([])

filename = System.argv() |> List.first

if File.exists?(filename) do
  IO.puts("Error: #{filename} already exists.")
else
  contents = "#!/usr/bin/env elixir

# Mix.install([])

IO.puts(\"Hello world\")
"
  File.write(filename, contents)
  File.chmod(filename, 0o755)
  IO.puts("#{filename} created.")
end

