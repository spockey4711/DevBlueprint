# Quality gate for a Go backend service. `make check` runs the whole gate; CI
# calls the same targets. Assumes gofumpt and golangci-lint are on PATH (see
# setup.sh / .tool-versions).
.PHONY: check lint format vet build test tidy clean

check: lint vet build test

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
