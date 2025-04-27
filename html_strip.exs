#!/usr/bin/env elixir

Mix.install([:floki])

defmodule HTMLStrip do
  # def strip_tags_with_floki(html) do
  #   # Parse the HTML and extract text nodes
  #   html
  #   |> Floki.parse()
  #   |> Floki.text()
  # end

  def strip_tags(html) do
    # # Simple regex to match HTML tags
    # regex = ~r/<[^>]*>/ 
    # # Replace matched HTML tags with an empty string
    # Regex.replace(regex, html, "")
    Floki.text(html)
  end

  def strip_tags_from_file(filepath) do
    {:ok, content} = File.read(filepath)
     stripped = strip_tags(content)
    IO.inspect(stripped)
  end

end

case System.argv() do
  [filename | _] -> File.read(filename) #HTMLStrip.strip_tags_from_file(filename)
  _ -> IO.puts("Abort. Received nothing.")
end
