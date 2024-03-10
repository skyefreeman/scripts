#!/usr/bin/env elixir

Mix.install([:openai_ex])

defmodule OpenAI do

  alias OpenaiEx.ChatCompletion
  alias OpenaiEx.ChatMessage
  
  def get_completion(system, prompt) do
    openai =
      OpenaiEx.new("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")
      |> OpenaiEx.with_receive_timeout(45_000)
    
    chat_req =
      ChatCompletion.new(
	model: "gpt-4",
	messages: [
	  ChatMessage.system(system),
	  ChatMessage.user(prompt)
	]
      )

    openai
    |> ChatCompletion.create(chat_req)
    |> Map.get("choices")
    |> Enum.at(0)
    |> Map.get("message")
    |> Map.get("content")
  end
end

cheese_names = ["Beaufort",
 "Chaource",
 "Cream Cheese",
 "Taleggio",
 "abondance",
 "babybel",
 "barbirousse",
 "bleu d'auvergne",
 "boursin",
 "brie de meaux",
 "cabecou",
 "camembert",
 "cantal",
 "caprice des dieux",
 "chabichou",
 "cheese curds",
 "chèvre cendré",
 "crottin de chavignol",
 "dubliner",
 "époisses",
 "feta",
 "fondue",
 "fontina",
 "fried queso",
 "fromager d'affinois",
 "gorgonzola dolce",
 "gouda",
 "kraft singles",
 "le coeur de bray",
 "manchego",
 "maroilles",
 "mimolette",
 "mont d'or",
 "mozzarella",
 "ossau iraty",
 "p'tit basque",
 "paneer",
 "parmesan",
 "pepper jack",
 "port salut",
 "pouligny st. pierre",
 "raclette",
 "reblochon",
 "red leiceister",
 "requeijao",
 "rocamadour",
 "roquefort",
 "saint albray",
 "seaside cheddar",
 "selles sur cher",
 "st. andré",
 "st. félicien",
 "st. nectaire",
 "ste maure de touraine",
 "stilton",
 "stracchino",
 "string cheese",
 "tome de savoie",
 "truffle brie",
 "vache qui rit",
]


cheese_names
|> Enum.each(fn name ->
  # Generate text completion
  response =
    OpenAI.get_completion(
      "You are a writing assistant. You will receieve a type of cheese, then write a 60 word paragraph describing its unique characteristics.",
      name
    )

  # save to file
  dir = "/Users/skye/dev/CheeseByJGDebray/web/static/descriptions/"
  filepath = dir <> "#{name}.txt"
  File.mkdir(dir)
  File.write!(filepath, response)

  # output
  IO.puts("**********************************")
  IO.puts("#{name}")
  IO.puts("")
  IO.puts("- #{response}")
  IO.puts("")
  IO.puts("- Wrote to #{name}.text")
  IO.puts("**********************************")
end)
