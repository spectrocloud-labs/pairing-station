#!/bin/bash

# TODO: setup git duet

set -e

if [[ -z "${EDGEVPNTOKEN}" ]]; then
  echo "EDGEVPNTOKEN env variable should be defined."
  echo "Check out: https://mudler.github.io/edgevpn/docs/getting-started/cli/#generate-a-network-token"
  exit 1
fi

if [[ -n "${SSH_USERS}" ]]; then
  export IFS=','
  for u in "${SSH_USERS}"; do
    curl https://github.com/${u}.keys >> ~/.ssh/authorized_keys
  done
fi

# Run ssh server in the background
sudo /usr/sbin/sshd -D -p 2222 &

# Start edgevpn service in the background
edgevpn service-add "PairingSSH" "127.0.0.1:2222" &
tmux new -s pairing
