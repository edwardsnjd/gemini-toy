.PHONY: setup run test clean devenv

setup:
	@bash scripts/setup.sh

run:
	@bash scripts/start-server.sh

test:
	@bash scripts/run-all-tests.sh

clean:
	@bash scripts/clean.sh

devenv: .devenv-image
	@bash scripts/devenv.sh

.devenv-image: Dockerfile.dev
	@bash scripts/build-devenv.sh
	touch .devenv-image
