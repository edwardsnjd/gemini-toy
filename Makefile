.PHONY: build
build:
	podman build --tag gemini-toy-dev --file Dockerfile.dev .

.PHONY: dev
dev:
	podman run --rm -ti -v $$PWD:$$PWD -w $$PWD gemini-toy-dev
