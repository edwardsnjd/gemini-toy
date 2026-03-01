#!/usr/bin/env bash

# Kill the existing dev container

if [[ ! -f .devenv-name ]]; then
  echo "Devenv isn't running" > /dev/stderr
  exit 1
fi

devenvContainerId="$(cat .devenv-name)"
podman kill "$devenvContainerId"

rm .devenv-name
