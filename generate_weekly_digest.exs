#!/usr/bin/env elixir

defmodule WeeklyDigest do
  @magazines_path "/Users/skyefreeman/dev/magazines-2025/"
  @kindle_email "skyefreeman_497558@kindle.com"
  @from_email "skye@swiftstarterkits.com"
  @email_script_path "/Users/skyefreeman/scripts/email_send.exs"
  
  @magazine_configs [
    %{code: "TE", name: "The Economist"},
    %{code: "NY", name: "New Yorker"}, 
    %{code: "SA", name: "Scientific American"},
    %{code: "TI", name: "Time"}
  ]

  def main do
    IO.puts("Starting Weekly Digest Generation...")
    
    magazines_dir = Path.expand(@magazines_path)
    
    unless File.exists?(magazines_dir) do
      IO.puts("Error: Magazines directory #{magazines_dir} does not exist")
      System.halt(1)
    end
    
    # Change to magazines directory and pull latest
    update_magazines_repo(magazines_dir)
    
    # Find and send latest magazines
    @magazine_configs
    |> Enum.each(&process_magazine(&1, magazines_dir))

    IO.puts("Weekly digest generation completed!")
  end

  def update_magazines_repo(magazines_dir) do
    IO.puts("Updating magazines repository...")
    
    case System.cmd("git", ["pull"], cd: magazines_dir) do
      {output, 0} ->
        IO.puts("Git pull successful:")
        IO.puts(output)
      {error, exit_code} ->
        IO.puts("Git pull failed with exit code #{exit_code}:")
        IO.puts(error)
        IO.puts("Continuing with existing files...")
    end
  end

  def process_magazine(%{code: code, name: name}, magazines_dir) do
    IO.puts("\\nProcessing #{name} (#{code})...")
    
    magazine_path = Path.join(magazines_dir, code)
    IO.puts("path")
    IO.puts(magazine_path)
    
    unless File.exists?(magazine_path) do
      IO.puts("Warning: #{name} directory #{magazine_path} does not exist, skipping...")
    else
      case find_latest_epub(magazine_path, code) do
        {:ok, epub_path} ->
          IO.puts("Found latest #{name}: #{epub_path}")
          send_magazine_email(epub_path, name)
        {:error, reason} ->
          IO.puts("Warning: Could not find latest #{name} epub: #{reason}")
      end
    end
  end

  def find_latest_epub(magazine_path, code) do
    IO.puts("Searching for year directories in: #{magazine_path}")
    year_dirs = magazine_path |> File.ls!() |> Enum.sort(:desc)
    IO.puts("Found year directories: #{inspect(year_dirs)}")
    
    case year_dirs do
      [] ->
        {:error, "No year directories found in #{magazine_path}"}
      [latest_year | _] ->
        IO.puts("Using latest year: #{latest_year}")
        find_latest_epub_in_year(magazine_path, latest_year, code)
    end
  end

  def find_latest_epub_in_year(magazine_path, year, code) do
    path = Path.join(magazine_path, year)
    date_dirs = path
    |> File.ls!()
    |> Enum.sort(:desc)
    
    case date_dirs do
      [] ->
        {:error, "No date directories found in #{year}"}
      [latest_date | _] ->
        find_epub_in_date_dir(path, latest_date, code)
    end
  end

  def find_epub_in_date_dir(year_path, date, code) do
    date_path = Path.join(year_path, date)
    
    epub_files = date_path
    |> File.ls!()
    |> Enum.filter(&String.ends_with?(&1, ".epub"))
    |> Enum.filter(&String.starts_with?(&1, code))
    |> Enum.sort()
    
    case epub_files do
      [] ->
        {:error, "No epub files found in #{date_path}"}
      [first_epub | _] ->
        {:ok, Path.join(date_path, first_epub)}
    end
  end

  def send_magazine_email(epub_path, magazine_name) do
    today = Date.utc_today()
    subject = "Weekly Digest - #{magazine_name} - #{Calendar.strftime(today, "%m/%d/%Y")}"
    
    args = [
      @email_script_path,
      "--provider", "local",
      "--attach", epub_path,
      @kindle_email,
      @from_email,
      subject,
      ""
    ]
    
    IO.puts("Sending #{magazine_name} to Kindle...")
    IO.puts("Command: #{Enum.join(args, " ")}")
    
    case System.cmd("elixir", args) do
      {output, 0} ->
        IO.puts("✓ #{magazine_name} sent successfully")
        IO.puts(output)
      {error, exit_code} ->
        IO.puts("✗ Failed to send #{magazine_name} (exit code: #{exit_code})")
        IO.puts(error)
    end
  end
end

# WeeklyDigest.main()
