#!/bin/bash

cleanup() {
  # Stop service-connect
  PS_ID=$(ps aux | grep "edgevpn service-connect PairingSSH" | grep -v grep | awk '{print $2}')
  if [ -n "${PS_ID}" ]; then
    kill $(ps aux | grep "edgevpn service-connect PairingSSH" | grep -v grep | awk '{print $2}')
  fi

  command="docker stop pairing-station"
  if [[ -z "${VM_CONNECT}" ]]; then
    eval "${command}"
  else
    ssh -t "${VM_CONNECT}" "${command}" || true
  fi
}

start() {
  cleanup

  command="docker run -d --name pairing-station \
  --privileged \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --rm --user 1000:1001 \
  -it -v "${PWD}":/home/dev/workspace \
  -e GITHUB_USERS="${GITHUB_USERS}" \
  -e EDGEVPNTOKEN=${EDGEVPNTOKEN} \
  ghcr.io/spectrocloud-labs/pairing-station:main /bin/bash"

  if [[ -z "${VM_CONNECT}" ]]; then
    eval "${command}"
  else
    ssh -t "${VM_CONNECT}" "${command}"
  fi
}

export TOKEN_FILE=$(mktemp)

if [[ -z "${EDGEVPNTOKEN}" ]]; then
  echo "EDGEVPNTOKEN env variable not defined."
  echo "Check out: https://mudler.github.io/edgevpn/docs/getting-started/cli/#generate-a-network-token"
  echo "Will generate one"
  export EDGEVPNTOKEN=$(edgevpn -g -b)
fi

echo "Writing token to ${TOKEN_FILE}"
echo $EDGEVPNTOKEN > "${TOKEN_FILE}"

if [[ -z "${GITHUB_USERS}" ]]; then
  echo "GITHUB_USERS should be set to a comma separated list of github users"
  exit 1
fi

start

echo "Done!"
echo "Connect with these commands:"
echo
echo 'export EDGEVPNTOKEN=$(cat '"${TOKEN_FILE}"')'
echo 'edgevpn service-connect "PairingSSH" "127.0.0.1:2222" > /tmp/pairing-edgevpn.logs 2>&1 &'
echo 'ssh dev@127.0.0.1 -p 2222'
echo
echo '(the last command might take a few retries before it succeeds)'
echo 'Run `tmux attach` after you succesfully ssh to the box`'
echo
echo "Send over ${TOKEN_FILE} to the other devs (${GITHUB_USERS}) so they can connect too using the same commands."
echo
