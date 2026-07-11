# Quality gate for a Go backend service. `make check` runs the whole gate; CI
# calls the same targets. Assumes gofumpt and golangci-lint are on PATH (see
# setup.sh / .tool-versions).
.PHONY: check validate-env lint format vet build test tidy clean

check: validate-env lint vet build test

# Enforce the environment contract: .env.example must stay in lockstep with
# .env.schema, and a real .env (if present) must satisfy every required key. This
# is stack-agnostic and always on - fill in the schema, not this target.
validate-env:
	@sh scripts/check-env.sh

lint:
	@test -z "$$(gofumpt -l .)" || { echo "Unformatted files (run 'make format'):"; gofumpt -l .; exit 1; }
	golangci-lint run

format:
	gofumpt -w .

vet:
	go vet ./...

build:
	go build ./...

test:
	go test -race -coverprofile=coverage.out ./...

tidy:
	go mod tidy

clean:
	go clean -cache -testcache
	rm -f coverage.out
