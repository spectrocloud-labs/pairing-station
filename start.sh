#!/bin/bash

if [[ -z "${EDGEVPNTOKEN}" ]]; then
  echo "EDGEVPNTOKEN env variable should be defined."
  echo "Check out: https://mudler.github.io/edgevpn/docs/getting-started/cli/#generate-a-network-token"
  exit 1
fi

if [[ -z "${GITHUB_USERS}" ]]; then
  echo "GITHUB_USERS should be set to a comma separated list of github users"
  exit 1
fi

docker run -it -e GITHUB_USERS="${GITHUB_USERS}" -e EDGEVPNTOKEN=${EDGEVPNTOKEN} pairing-station /bin/bash
