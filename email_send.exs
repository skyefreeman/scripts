#!/usr/bin/env elixir

Mix.install([
  :sendgrid,
  :httpoison,
  :jason
])

defmodule EmailSend do
  def main do
    args = System.argv()
    
    case args do
      ["--provider", provider, to, from, subject, content] -> 
        send_email(String.to_atom(provider), to, from, subject, content)
      ["--provider", provider, to, from, subject] ->
        content = read_stdin()
        send_email(String.to_atom(provider), to, from, subject, content)
      [to, from, subject, content] -> 
        send_email(:sendgrid, to, from, subject, content)
      [to, from, subject] ->
        content = read_stdin()
        send_email(:sendgrid, to, from, subject, content)
      _ ->
        print_usage()
        System.halt(1)
    end
  end

  def send_email(provider, to, from, subject, content) do
    case provider do
      :sendgrid -> send_via_sendgrid(to, from, subject, content)
      :mailgun -> send_via_mailgun(to, from, subject, content)
      _ -> 
        IO.puts("Error: Unsupported provider '#{provider}'. Supported providers: sendgrid, mailgun")
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

  defp send_via_mailgun(to, from, subject, content) do
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
    
    form_data = [
      {"from", from},
      {"to", to},
      {"subject", subject},
      {"text", content}
    ]

    encoded = Base.encode64("api:#{api_key}")
    headers = [
      {"Authorization", "Basic #{encoded}"},
      {"Content-Type", "application/x-www-form-urlencoded"}
    ]
    
    body = URI.encode_query(form_data)
    
    result = HTTPoison.post(url, body, headers)
    
    case result do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        handle_result(:ok, "Mailgun")
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        handle_result({:error, "HTTP #{status_code}: #{body}"}, "Mailgun")
      {:error, reason} ->
        handle_result({:error, reason}, "Mailgun")
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

  defp print_usage do
    IO.puts("Usage:")
    IO.puts("  ./email_send.exs [--provider sendgrid|mailgun] \"recipient@example.com\" \"from@example.com\" \"Subject\" \"Email content\"")
    IO.puts("  echo \"Email content\" | ./email_send.exs [--provider sendgrid|mailgun] \"recipient@example.com\" \"from@example.com\" \"Subject\"")
    IO.puts("")
    IO.puts("Providers:")
    IO.puts("  sendgrid (default) - Requires SENDGRID_API_KEY environment variable")
    IO.puts("  mailgun            - Requires MAILGUN_API_KEY and MAILGUN_DOMAIN environment variables")
  end

  defp read_stdin do
    IO.read(:stdio, :eof)
    |> String.trim()
  end
end

EmailSend.main()
