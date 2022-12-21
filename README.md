# Treat your pairing station like cattle, not pet!

This project is a way to create a pairing station to which developers can easily ssh.
This is not meant to be a permanent box so whatever changes you make, make sure you make them in this repo.

## Build the image


```bash
docker build -t pairint-station .
```

## Start a container

The pairing container can be started anywhere, on your workstation, the cloud,
Kubernetes etc. It just needs to be able to run containers.

From the machine of your choice, do the following.

First you are going to need an edgevpn token. This is the only thing that needs
to be shared among the developers.

Follow [the instructions](https://mudler.github.io/edgevpn/docs/getting-started/cli/#generate-a-network-token) to generate a new token:

```bash
edgevpn -g -b > pairing.token
```

```bash
export EDGEVPNTOKEN=$(cat pairing.token)
export GITHUB_USERS="jimmykarily,mauromorales,oz123"
./start.sh
```

## Connect and pair

Any developer in GITHUB_USERS can now connect to the container with these 2 commands:

```bash
export EDGEVPNTOKEN=$(cat pairing.token)
edgevpn service-connect "PairingSSH" "127.0.0.1:2222" &
ssh dev@127.0.0.1 -p 2222
```

Run `tmux attach` to connect to the running tmux session.
