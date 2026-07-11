# Quality gate for an Elixir / Phoenix project. `make check` runs the whole gate;
# CI calls the same tools. Everything runs through `mix`, so the versions are the
# ones pinned in mix.lock and .tool-versions - local, CI and teammates match.
.PHONY: check validate-env format format-check lint typecheck test build serve deps clean

check: validate-env format-check lint typecheck test

# Enforce the environment contract: .env.example must stay in lockstep with
# .env.schema, and any real .env must satisfy the schema's required keys and
# patterns. Runs first so a misconfigured environment fails fast.
validate-env:
	@sh scripts/check-env.sh

# format-check verifies formatting is canonical (mix format); lint runs Credo
# (style + consistency + complexity); typecheck runs Dialyzer (success-typing
# static analysis). Kept as separate targets so a red one is obvious.
format-check:
	mix format --check-formatted

format:
	mix format

lint:
	mix credo --strict

typecheck:
	mix dialyzer

test:
	mix test

build:
	MIX_ENV=prod mix compile --warnings-as-errors

serve:
	mix phx.server

deps:
	mix deps.get

clean:
	mix clean && rm -rf _build cover
