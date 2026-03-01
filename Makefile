.PHONY: setup run test clean devenv-up devenv-down

setup:
	@bash scripts/setup.sh

run:
	@bash scripts/start-server.sh

test:
	@bash scripts/run-all-tests.sh

clean:
	@bash scripts/clean.sh

.devenv-image: Dockerfile.dev
	@bash scripts/build-devenv.sh
	touch .devenv-image

devenv-up: .devenv-image
	@bash scripts/devenv-up.sh

devenv-down:
	@bash scripts/devenv-down.sh

