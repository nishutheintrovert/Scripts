#!/usr/bin/env bash

env="$HOME/.ssh/agent.env"

agent_load_env() {
    test -f "$env" && . "$env" >/dev/null
}

agent_start() {
    (
        umask 077
        ssh-agent >"$env"
    )
    . "$env" >/dev/null
}

agent_load_env

# Start agent only if not already running
if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
    agent_start
fi

# Check if the vault has any keys loaded
# ssh-add -l returns 1 if no keys are found, triggering the ssh-add prompt
if ! ssh-add -l >/dev/null 2>&1; then
    ssh-add
fi
