#!/bin/bash

# Create the directories for the challenge
read -p "Which challenge category do you wanna create (pwn/rev/web/crypto/etc...): " chall_category

if [ ! -d $chall_category ]; then
  echo "Creating category directory"
  mkdir $chall_category
fi

read -p "Please enter the challenge name: " chall_name

current_dir=$chall_category/$chall_name

if [ ! -d $current_dir ]; then
  echo "Creating challenge directory"
  mkdir $current_dir
fi

mkdir $current_dir/dist $current_dir/src $current_dir/writeup

cp template/challenge.yml template/docker-compose.yaml template/Dockerfile template/flag.txt $current_dir
