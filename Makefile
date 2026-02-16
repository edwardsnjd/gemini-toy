.PHONY: setup run test clean

setup:
	@bash scripts/setup.sh

run:
	@bash scripts/start-server.sh

test:
	@bash scripts/run-all-tests.sh

clean:
	@bash scripts/clean.sh
