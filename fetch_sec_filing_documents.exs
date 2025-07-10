#!/usr/bin/env elixir

Mix.install([
  {:httpoison, "~> 2.0"},
  {:jason, "~> 1.4"}
])

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
    case System.argv() do
      [cik] -> 
        fetch_company_filings(cik)
      [cik, form_type] -> 
        fetch_company_filings(cik, form_type)
      _ -> 
        IO.puts("Usage: elixir fetch_sec_filing_documents.exs <CIK> [form_type]")
        IO.puts("Example: elixir fetch_sec_filing_documents.exs 0000320193")
        IO.puts("Example: elixir fetch_sec_filing_documents.exs 0000320193 10-K")
    end
  end

  def fetch_company_filings(cik, form_type \\ nil) do
    cik = format_cik(cik)
    
    IO.puts("Fetching filings for CIK: #{cik}")
    
    case get_company_submissions(cik) do
      {:ok, data} ->
        ticker = extract_ticker(data)
        filings = extract_filings(data, form_type)
        display_filings(filings)
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

  defp display_filings(filings) do
    IO.puts("\nFound #{length(filings)} filings:")
    IO.puts(String.duplicate("-", 80))
    
    filings
    |> Enum.each(fn filing ->
      IO.puts("Form: #{filing.form}")
      IO.puts("Accession Number: #{filing.accession_number}")
      IO.puts("Filing Date: #{filing.filing_date}")
      IO.puts("Report Date: #{filing.report_date}")
      IO.puts(String.duplicate("-", 40))
    end)
  end

  defp extract_document_urls(filings, ticker) do
    IO.puts("\nGenerating document URLs...")
    
    filings
    |> Enum.each(fn filing ->
      IO.puts("\n#{filing.form} - #{filing.filing_date}")
      IO.puts("Accession: #{filing.accession_number}")
      
      # Generate direct URLs to common filing documents
      urls = generate_direct_urls(filing, ticker)
      
      urls
      |> Enum.each(fn url ->
        IO.puts("  Document URL: #{url}")
      end)
    end)
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


