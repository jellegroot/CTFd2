#!/bin/bash
set -e

if ! command -v ctf &>/dev/null; then
  echo "Error: ctfcli is not installed. Installing now with pipx"
  pipx install ctfcli
fi

if [ -z "$1" ]; then
  echo "Error: Challenge name argument required"
  exit 1
fi

if [ ! -f "$1/docker-compose.yaml" ]; then
  echo "Error: docker-compose.yaml not found in $1"
  exit 1
fi

echo "Deploying the challenge to CTFd"

# initialize the ctf cli tool and connect to CTFd
echo "INFO the admin access token is located under settings -> access token"
if [ ! -d ".ctf" ]; then
  ctf init
fi

docker compose -f $1/docker-compose.yaml up -d

# Ctf cli commands
ctf challenge add $1 >/dev/null 2>&1 </dev/null
ctf challenge install $1 >/dev/null 2>&1 </dev/null
ctf challenge sync $1 >/dev/null 2>&1 </dev/null
ctf challenge deploy $1 >/dev/null 2>&1 </dev/null

echo ""
echo "Done! Check the CTFd challenge page."
