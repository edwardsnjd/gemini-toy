#!/usr/bin/env bash

# Run a command in the existing dev container.

if [[ ! -f .devenv-name ]]; then
  echo "Devenv isn't running" > /dev/stderr
  exit 1
fi

devenvContainerId="$(cat .devenv-name)"
exec podman exec -ti "$devenvContainerId" "$@"
