#!/usr/bin/env elixir

# Mix.install([])

wait_in_seconds = System.argv() |> List.first |> String.to_integer
wait_in_minutes = wait_in_seconds/60

IO.puts("Timer set for #{wait_in_minutes} minutes...")

:timer.sleep(:timer.seconds(wait_in_seconds))

_ = System.cmd("say", ["Hey Skye, take a break and go for a walk."])
