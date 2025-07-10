#!/usr/bin/env elixir

Mix.install([
  {:httpoison, "~> 2.0"},
  {:jason, "~> 1.4"}
])

# Disable logger to prevent "writer crash" errors when piping.
Logger.configure(level: :emergency)

defmodule SECFilingFetcher do
  @moduledoc """
  Script to fetch SEC EDGAR filing documents (10-K, 10-Q, etc.) using the SEC's JSON API.
  
  The SEC requires a User-Agent header that identifies the requester.
  Rate limit: 10 requests per second maximum.
  """

  @base_url "https://data.sec.gov"
  @archive_base_url "https://sec.gov"
  @user_agent "SEC Filing Fetcher 1.0 (your-email@example.com)"

  def start do
    args = System.argv()
    parse_args(args)
  end

  defp parse_args(["-c", cik | rest]) do
    form_type = case rest do
      [type] -> type
      _ -> nil
    end
    fetch_company_filings(cik, form_type)
  end

  defp parse_args(["-t"]) do
    fetch_and_display_all_tickers()
  end

  defp parse_args(["-t", search_text]) do
    search_tickers(search_text)
  end

  defp parse_args(_) do
    IO.puts("Usage:")
    IO.puts("  elixir fetch_sec_filing_documents.exs -c <CIK> [form_type]")
    IO.puts("  elixir fetch_sec_filing_documents.exs -t [search_text]")
    IO.puts("")
    IO.puts("Examples:")
    IO.puts("  elixir fetch_sec_filing_documents.exs -c 0000320193")
    IO.puts("  elixir fetch_sec_filing_documents.exs -c 0000320193 10-K")
    IO.puts("  elixir fetch_sec_filing_documents.exs -t")
    IO.puts("  elixir fetch_sec_filing_documents.exs -t APPLE")
  end

  def fetch_company_filings(cik, form_type \\ nil) do
    cik = format_cik(cik)
    
    case get_company_submissions(cik) do
      {:ok, data} ->
        ticker = extract_ticker(data)
        filings = extract_filings(data, form_type)
        extract_document_urls(filings, ticker)
        
      {:error, reason} ->
        IO.puts("Error: #{reason}")
    end
  end

  defp format_cik(cik) do
    cik
    |> String.replace_leading("0", "")
    |> String.to_integer()
    |> Integer.to_string()
    |> String.pad_leading(10, "0")
  end

  defp get_company_submissions(cik) do
    url = "#{@base_url}/submissions/CIK#{cik}.json"
    
    headers = [
      {"User-Agent", @user_agent},
      {"Accept", "application/json"},
      {"Host", "data.sec.gov"}
    ]
    
    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} -> {:ok, data}
          {:error, _} -> {:error, "Failed to parse JSON response"}
        end
        
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Company not found (CIK: #{cik})"}
        
      {:ok, %HTTPoison.Response{status_code: 429}} ->
        {:error, "Rate limit exceeded. Please wait and try again."}
        
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "HTTP error: #{status_code}"}
        
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed: #{reason}"}
    end
  end

  defp extract_filings(data, form_type) do
    recent_filings = data["filings"]["recent"]
    
    forms = recent_filings["form"]
    accession_numbers = recent_filings["accessionNumber"]
    filing_dates = recent_filings["filingDate"]
    report_dates = recent_filings["reportDate"]
    
    forms
    |> Enum.with_index()
    |> Enum.filter(fn {form, _index} ->
      case form_type do
        nil -> form in ["10-K", "10-Q", "8-K", "10-K/A", "10-Q/A"]
        type -> String.contains?(form, type)
      end
    end)
    |> Enum.map(fn {form, index} ->
      %{
        form: form,
        accession_number: Enum.at(accession_numbers, index),
        filing_date: Enum.at(filing_dates, index),
        report_date: Enum.at(report_dates, index)
      }
    end)
  end

  defp extract_document_urls(filings, ticker) do
    filings
    |> Enum.sort_by(& &1.report_date)
    |> Enum.each(fn filing ->
      [url] = generate_direct_urls(filing, ticker)
      
      filing_json = %{
        "report_date" => filing.report_date,
        "form" => filing.form,
        "accession_number" => filing.accession_number,
        "filing_url" => url
      }
      
      safe_puts("#{Jason.encode!(filing_json)}")
    end)
  end

  def fetch_and_display_all_tickers do
    case get_company_tickers() do
      {:ok, tickers} ->
        display_tickers(tickers)
      {:error, reason} ->
        IO.puts("Error: #{reason}")
    end
  end

  def search_tickers(search_text) do
    case get_company_tickers() do
      {:ok, tickers} ->
        matching_tickers = filter_tickers(tickers, search_text)
        display_tickers(matching_tickers)
      {:error, reason} ->
        IO.puts("Error: #{reason}")
    end
  end

  defp get_company_tickers do
    url = "https://www.sec.gov/files/company_tickers.json"
    
    headers = [
      {"User-Agent", @user_agent},
      {"Accept", "application/json"}
    ]
    
    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} ->
            # Convert the nested structure to a list of company maps
            tickers = data
            |> Map.values()
            |> Enum.map(fn company ->
              %{
                "cik_str" => company["cik_str"],
                "ticker" => company["ticker"],
                "title" => company["title"]
              }
            end)
            {:ok, tickers}
          {:error, _} ->
            {:error, "Failed to parse company tickers JSON"}
        end
        
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "HTTP error: #{status_code}"}
        
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Request failed: #{reason}"}
    end
  end

  defp filter_tickers(tickers, search_text) do
    search_lower = String.downcase(search_text)
    
    tickers
    |> Enum.filter(fn ticker ->
      ticker_match = String.contains?(String.downcase(ticker["ticker"]), search_lower)
      title_match = String.contains?(String.downcase(ticker["title"]), search_lower)
      ticker_match || title_match
    end)
  end

  defp display_tickers(tickers) do
    tickers
    |> Enum.each(fn ticker ->
      safe_puts("#{Jason.encode!(ticker)}")
    end)
  end

  defp safe_puts(message) do
    try do
      IO.puts(message)
    rescue
      ErlangError -> 
        # Handle broken pipe error when output is piped to commands like head
        exit(:normal)
    catch
      :exit, :terminated ->
        # Handle case where stdout is terminated
        exit(:normal)
    end
  end

  defp extract_cik_from_accession(accession_number) do
    # Extract CIK from accession number format: NNNNNNNNNN-NN-NNNNNN
    accession_number
    |> String.split("-")
    |> List.first()
    |> String.to_integer()
    |> Integer.to_string()
  end

  defp extract_ticker(data) do
    # Extract ticker from the company data
    # The ticker is typically in the "tickers" field or can be derived from other fields
    tickers = data["tickers"]
    
    if tickers && length(tickers) > 0 do
      # Get the first ticker and convert to lowercase
      tickers
      |> List.first()
      |> String.downcase()
    else
      # Fallback: try to extract from company name or use "unknown"
      "unknown"
    end
  end

  defp generate_direct_urls(filing, ticker) do
    clean_accession = String.replace(filing.accession_number, "-", "")
    cik = extract_cik_from_accession(filing.accession_number)
    
    # Generate document name using ticker and report date
    # Format: ticker-YYYYMMDD (e.g., aapl-20240928)
    clean_date = String.replace(filing.report_date, "-", "")
    document_name = "#{ticker}-#{clean_date}"
    
    # Generate URLs for common filing document patterns
    base_url = "#{@archive_base_url}/Archives/edgar/data/#{cik}/#{clean_accession}"
    
    [
      "#{base_url}/#{document_name}.htm"
    ]
  end
end

SECFilingFetcher.start()
