# Quality gate for a Rust project (cargo). `make check` runs the whole gate; CI
# calls the same targets. clippy is both the linter and the type-aware analysis,
# so there is no separate typecheck target.
.PHONY: check lint format test build clean

check: lint test

lint:
	cargo fmt --check
	cargo clippy --all-targets --all-features -- -D warnings

format:
	cargo fmt
	cargo clippy --fix --allow-dirty --allow-staged --all-targets --all-features

test:
	cargo test --all-features

build:
	cargo build --release

clean:
	cargo clean
