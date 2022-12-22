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

# Run privileged if you want to be able to run docker inside (e.g. for Earthly)
docker run --name pairing-station \
  --privileged -v /var/run/docker.sock:/var/run/docker.sock \
  --rm -d --user 1000:1001 \
  -it -v workspace:/home/dev/workspace \
  -e GITHUB_USERS="${GITHUB_USERS}" \
  -e EDGEVPNTOKEN=${EDGEVPNTOKEN} \
  ghcr.io/spectrocloud-labs/pairing-station:main /bin/bash
