# Quality gate for a Rust project (cargo). `make check` runs the whole gate; CI
# calls the same targets. clippy is both the linter and the type-aware analysis,
# so there is no separate typecheck target.
.PHONY: check validate-env lint format test build clean

check: validate-env lint test

# Enforce the environment contract: .env.example must stay in lockstep with
# .env.schema, and a real .env (if present) must satisfy every required key. This
# is stack-agnostic and always on - fill in the schema, not this target.
validate-env:
	@sh scripts/check-env.sh

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
