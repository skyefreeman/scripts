#!/usr/bin/env elixir

Mix.install([
  :openai_ex,
  :sendgrid
])

defmodule GptToEmail do

  def main do
    args = System.argv()
    
    case args do
      [prompt, to, from, subject] -> process_prompt_and_send_email(prompt, to, from, subject)
      _ ->
        IO.puts("Usage: ./gpt_to_email.exs \"your prompt\" \"recipient@example.com\" \"from@example.com\" \"Email subject\"")
        System.halt(1)
    end
  end

  def process_prompt_and_send_email(prompt, to, from, subject) do
    IO.puts("Processing prompt: #{prompt}")
    # Get response from GPT
    response = get_gpt_completion(prompt)

    IO.puts("Done. Will send to: #{to}")

    # Send email with the response
    send_email(to, from, subject, response)
  end

  def get_gpt_completion(prompt) do
    openai =
      OpenaiEx.new(System.get_env("OPENAI_API_KEY"))
      |> OpenaiEx.with_receive_timeout(45_000)
    
    chat_req =
      OpenaiEx.Chat.Completions.new(
        model: "gpt-4",
        messages: [
          OpenaiEx.ChatMessage.system("You are a helpful assistant."),
          OpenaiEx.ChatMessage.user(prompt)
        ]
      )

    {:ok, response} = openai |> OpenaiEx.Chat.Completions.create(chat_req)

    response
    |> Map.get("choices")
    |> Enum.at(0)
    |> Map.get("message")
    |> Map.get("content")
  end

  def send_email(to, from, subject, content) do
    api_key = System.get_env("CRON_GPT_SENDGRID_KEY")
    
    result =
      SendGrid.Email.build()
      |> SendGrid.Email.add_to(to)
      |> SendGrid.Email.put_from(from)
      |> SendGrid.Email.put_subject(subject)
      |> SendGrid.Email.put_text(content)
      |> SendGrid.Mail.send(api_key: api_key)

    IO.inspect(result)
    
    case result do
      :ok -> 
        IO.puts("Email sent successfully")
      {:error, reason} -> 
        IO.puts("Failed to send email: #{inspect(reason)}")
    end
  end
end

GptToEmail.main()
