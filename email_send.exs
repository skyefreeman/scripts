#!/usr/bin/env elixir

Mix.install([
  :sendgrid,
  :httpoison,
  :jason
])

defmodule EmailSend do
  def main do
    args = System.argv()
    
    case parse_args(args) do
      {:ok, {provider, to, from, subject, content, attachment}} ->
        send_email(provider, to, from, subject, content, attachment)
      {:error, :usage} ->
        print_usage()
        System.halt(1)
    end
  end

  defp parse_args(args) do
    case args do
      ["--provider", provider, "--attach", attachment, to, from, subject, content] ->
        {:ok, {String.to_atom(provider), to, from, subject, content, attachment}}
      ["--provider", provider, "--attach", attachment, to, from, subject] ->
        content = read_stdin()
        {:ok, {String.to_atom(provider), to, from, subject, content, attachment}}
      ["--attach", attachment, to, from, subject, content] ->
        {:ok, {:mailgun, to, from, subject, content, attachment}}
      ["--attach", attachment, to, from, subject] ->
        content = read_stdin()
        {:ok, {:mailgun, to, from, subject, content, attachment}}
      ["--provider", provider, to, from, subject, content] ->
        {:ok, {String.to_atom(provider), to, from, subject, content, nil}}
      ["--provider", provider, to, from, subject] ->
        content = read_stdin()
        {:ok, {String.to_atom(provider), to, from, subject, content, nil}}
      [to, from, subject, content] ->
        {:ok, {:sendgrid, to, from, subject, content, nil}}
      [to, from, subject] ->
        content = read_stdin()
        {:ok, {:sendgrid, to, from, subject, content, nil}}
      _ ->
        {:error, :usage}
    end
  end

  def send_email(provider, to, from, subject, content, attachment) do
    if attachment && provider not in [:mailgun, :local] do
      IO.puts("Error: Attachments are only supported with Mailgun and Local providers")
      System.halt(1)
    end
    
    case provider do
      :sendgrid -> send_via_sendgrid(to, from, subject, content)
      :mailgun -> send_via_mailgun(to, from, subject, content, attachment)
      :local -> send_via_local(to, from, subject, content, attachment)
      _ -> 
        IO.puts("Error: Unsupported provider '#{provider}'. Supported providers: sendgrid, mailgun, local")
        System.halt(1)
    end
  end

  defp send_via_sendgrid(to, from, subject, content) do
    api_key = System.get_env("SENDGRID_API_KEY")
    
    if is_nil(api_key) do
      IO.puts("Error: SENDGRID_API_KEY environment variable not set")
      System.halt(1)
    end
    
    result =
      SendGrid.Email.build()
      |> SendGrid.Email.add_to(to)
      |> SendGrid.Email.put_from(from)
      |> SendGrid.Email.put_subject(subject)
      |> SendGrid.Email.put_text(content)
      |> SendGrid.Mail.send(api_key: api_key)

    handle_result(result, "SendGrid")
  end

  defp send_via_mailgun(to, from, subject, content, attachment \\ nil) do
    api_key = System.get_env("MAILGUN_API_KEY")
    domain = System.get_env("MAILGUN_DOMAIN")
    
    if is_nil(api_key) do
      IO.puts("Error: MAILGUN_API_KEY environment variable not set")
      System.halt(1)
    end
    
    if is_nil(domain) do
      IO.puts("Error: MAILGUN_DOMAIN environment variable not set")
      System.halt(1)
    end
    
    url = "https://api.mailgun.net/v3/#{domain}/messages"
    encoded = Base.encode64("api:#{api_key}")
    
    result = if attachment do
      send_mailgun_with_attachment(url, encoded, to, from, subject, content, attachment)
    else
      send_mailgun_simple(url, encoded, to, from, subject, content)
    end
    
    case result do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        handle_result(:ok, "Mailgun")
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        handle_result({:error, "HTTP #{status_code}: #{body}"}, "Mailgun")
      {:error, reason} ->
        handle_result({:error, reason}, "Mailgun")
    end
  end

  defp send_via_local(to, from, subject, content, attachment \\ nil) do
    # Escape quotes and backslashes for AppleScript
    escaped_to = String.replace(to, "\"", "\\\"")
    escaped_from = String.replace(from, "\"", "\\\"")
    escaped_subject = String.replace(subject, "\"", "\\\"")
    escaped_content = String.replace(content, "\"", "\\\"") |> String.replace("\\n", "\\r")
    
    attachment_script = if attachment do
      unless File.exists?(attachment) do
        IO.puts("Error: Attachment file '#{attachment}' does not exist")
        System.halt(1)
      end
      
      escaped_attachment = String.replace(attachment, "\"", "\\\"")
      "make new attachment with properties {file name:\"#{escaped_attachment}\"} at after the last paragraph"
    else
      ""
    end
    
    applescript = """
    tell application "Mail"
        set newMessage to make new outgoing message with properties {subject:"#{escaped_subject}", content:"#{escaped_content}"}
        tell newMessage
            make new to recipient with properties {address:"#{escaped_to}"}
            set sender to "#{escaped_from}"
            #{if attachment_script != "", do: attachment_script}
        end tell
        set visible of newMessage to true
        activate
    end tell
    """
    
    case System.cmd("osascript", ["-e", applescript]) do
      {_output, 0} ->
        handle_result(:ok, "Local Mail")
      {error, exit_code} ->
        handle_result({:error, "osascript failed (#{exit_code}): #{error}"}, "Local Mail")
    end
  end

  defp handle_result(result, provider) do
    IO.inspect(result)
    
    case result do
      :ok -> 
        IO.puts("Email sent successfully via #{provider}")
      {:error, reason} -> 
        IO.puts("Failed to send email via #{provider}: #{inspect(reason)}")
        System.halt(1)
    end
  end

  defp send_mailgun_simple(url, encoded, to, from, subject, content) do
    form_data = [
      {"from", from},
      {"to", to},
      {"subject", subject},
      {"text", content}
    ]

    headers = [
      {"Authorization", "Basic #{encoded}"},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]
    
    body = URI.encode_query(form_data)
    HTTPoison.post(url, body, headers)
  end

  defp send_mailgun_with_attachment(url, encoded, to, from, subject, content, attachment_path) do
    unless File.exists?(attachment_path) do
      IO.puts("Error: Attachment file '#{attachment_path}' does not exist")
      System.halt(1)
    end
    
    filename = Path.basename(attachment_path)
    file_content = File.read!(attachment_path)
    
    boundary = "----formdata-elixir-#{:rand.uniform(1000000)}"
    
    form_parts = [
      build_form_part("from", from),
      build_form_part("to", to),
      build_form_part("subject", subject),
      build_form_part("text", content),
      build_file_part("attachment", filename, file_content)
    ]

    body = "--#{boundary}\r\n" <> Enum.join(form_parts, "\r\n--#{boundary}\r\n") <> "\r\n--#{boundary}--\r\n"
    
    headers = [
      {"Authorization", "Basic #{encoded}"},
      {"Content-Type", "multipart/form-data; boundary=#{boundary}"}
    ]
    
    HTTPoison.post(url, body, headers)
  end

  defp build_form_part(name, value) do
    "Content-Disposition: form-data; name=\"#{name}\"\r\n\r\n#{value}"
  end

  defp build_file_part(name, filename, content) do
    "Content-Disposition: form-data; name=\"#{name}\"; filename=\"#{filename}\"\r\n" <>
    "Content-Type: application/octet-stream\r\n\r\n" <>
    content
  end

  defp print_usage do
    IO.puts("Usage:")
    IO.puts("  ./email_send.exs [--provider sendgrid|mailgun|local] [--attach /path/to/file] \"recipient@example.com\" \"from@example.com\" \"Subject\" \"Email content\"")
    IO.puts("  echo \"Email content\" | ./email_send.exs [--provider sendgrid|mailgun|local] [--attach /path/to/file] \"recipient@example.com\" \"from@example.com\" \"Subject\"")
    IO.puts("")
    IO.puts("Options:")
    IO.puts("  --attach /path/to/file  Include file attachment (Mailgun and Local only)")
    IO.puts("")
    IO.puts("Providers:")
    IO.puts("  sendgrid (default) - Requires SENDGRID_API_KEY environment variable")
    IO.puts("  mailgun            - Requires MAILGUN_API_KEY and MAILGUN_DOMAIN environment variables")
    IO.puts("  local              - Opens email in macOS Mail app (requires macOS)")
    IO.puts("")
    IO.puts("Note: Attachments are supported with Mailgun and Local providers")
  end

  defp read_stdin do
    IO.read(:stdio, :eof)
    |> String.trim()
  end
end

EmailSend.main()
