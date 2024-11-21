#!/usr/bin/env elixir

# Mix.install([])

# docker run --rm --name 'skye' --log-driver json-file --log-opt max-size=1000m --log-opt max-file=3 -v /home/git:/home/git -it $(docker images | grep pushd/web | awk '{print $3}' | head -1) /bin/bash

defmodule SSHExample do
  def run_ssh_command do
    # Command to connect via SSH and execute 'ls' on the remote server
    command = "ssh"
    args = ["-A", "git@deploy.pushd.com",
	    "cat", "docker.run.latest.pushd-web.bash", "|",
	    "sed", "s/-it//g", "|", "sed", "'s/bash/bash ls/g'", "|", "eval"
	   ]

# PUSHD_DEPLOY=1 script/env production rails runner script/add_frame_feature.rb attachment_captions_on_frame
    
    # Execute the command
    {output, exit_status} = System.cmd(command, args)
    
    case exit_status do
      0 -> {:ok, output}
      _ -> {:error, {:exit_status, exit_status}}
    end
  end
end

# Running the SSH command
case SSHExample.run_ssh_command do
  {:ok, output} -> IO.puts("Command executed successfully:\n#{output}")
  {:error, {:exit_status, exit_status}} -> IO.puts("Command failed with status: #{exit_status}")
end

# ;; ssh -A git@deploy.pushd.com
# ;; ./docker.run.latest.pushd-web.bash steve
# ;; PUSHD_DEPLOY=1 script/env production rails runner script/send_add_photos_reminders.rb

#  ;; ./docker.run.latest.pushd-web.bash skye && PUSHD_DEPLOY=1 script/env production rails runner script/add_frame_feature.rb attachment_captions_on_frame

