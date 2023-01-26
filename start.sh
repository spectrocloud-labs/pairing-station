#!/bin/bash

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

# Run privileged if you want to be able to run docker inside (e.g. for Earthly)
docker run -d --name pairing-station \
  --privileged \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --rm --user 1000:1001 \
  -it -v "${PWD}":/home/dev/workspace \
  -e GITHUB_USERS="${GITHUB_USERS}" \
  -e EDGEVPNTOKEN=${EDGEVPNTOKEN} \
  ghcr.io/spectrocloud-labs/pairing-station:main /bin/bash

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
