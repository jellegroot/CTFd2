#!/bin/bash

#? Create network 
docker network create ctfd_net 2>/dev/null

#? build all the components
docker compose up -d 

#? Install pipx if not exists
if ! command -v pipx &> /dev/null; then
    echo "pipx could not be found, installing..."
    sudo apt update
    sudo apt install pipx
    pipx ensurepath
fi

echo "pipx is installed."
echo "Please read the challenge/readme.md for further instructions to set up the challenges."