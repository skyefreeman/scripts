#!/bin/bash

if [ -n "$SSH_CONNECTION" ]; then
    # Extract information from SSH_CONNECTION variable
    client_ip=$(echo $SSH_CONNECTION | awk '{print $1}')
    client_port=$(echo $SSH_CONNECTION | awk '{print $2}')
    
    echo "Current SSH Connection:"
    echo "Client IP: $client_ip"
    echo "Client Port: $client_port"
else
    echo "Not connected via SSH."
fi
