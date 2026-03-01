#!/usr/bin/env bash

# Run a container for the development environment
# building the image if required.

podman run \
  --rm \
  --tty \
  --interactive \
  --detach \
  --volume "$PWD":"$PWD" \
  --workdir "$PWD" \
  --env-file ".env" \
  gemini-toy-dev \
  > .devenv-name
