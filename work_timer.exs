#!/usr/bin/env elixir

# Mix.install([])

wait_in_seconds = System.argv() |> List.first |> String.to_integer

:timer.sleep(:timer.seconds(wait_in_seconds))

_ = System.cmd("say", ["Hey Skye, take a break and go for a walk."])
