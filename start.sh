#!/bin/bash

if [[ -z "${EDGEVPNTOKEN}" ]]; then
  echo "EDGEVPNTOKEN env variable should be defined."
  echo "Check out: https://mudler.github.io/edgevpn/docs/getting-started/cli/#generate-a-network-token"
  exit 1
fi

docker run -it -e EDGEVPNTOKEN=${EDGEVPNTOKEN} pairing-station /bin/bash
