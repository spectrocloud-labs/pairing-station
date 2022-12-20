#!/bin/bash

# TODO: setup git duet

set -e

if [[ -z "${EDGEVPNTOKEN}" ]]; then
  echo "EDGEVPNTOKEN env variable should be defined."
  echo "Check out: https://mudler.github.io/edgevpn/docs/getting-started/cli/#generate-a-network-token"
  exit 1
fi

if [[ -z "${GITHUB_USERS}" ]]; then
  echo "GITHUB_USERS should be set to a comma separated list of github users"
  exit 1
fi

mkdir ~/.ssh
export IFS=','
for u in `echo "${GITHUB_USERS}"`; do
  curl https://github.com/${u}.keys >> ~/.ssh/authorized_keys
done
chmod 600 ~/.ssh/authorized_keys

# Run ssh server in the background
sudo /usr/sbin/sshd -D -E /var/log/sshd.log -f /etc/ssh/sshd_config -p 2222 &

# Start edgevpn service in the background
edgevpn service-add "PairingSSH" "127.0.0.1:2222" 2>&1 > /home/dev/edgevpn.log &

tmux new -s pairing
