# Quality gate for a PHP / Laravel project. `make check` runs the whole gate; CI
# calls the same tools. Everything runs through the Composer-installed binaries
# in vendor/bin so local, CI and teammates use the versions pinned in
# composer.lock.
.PHONY: check validate-env lint format format-check test build serve clean install

check: validate-env format-check lint test

# Enforce the environment contract: .env.example must stay in lockstep with
# .env.schema, and a real .env (if present) must satisfy every required key. This
# is stack-agnostic and always on - fill in the schema, not this target.
validate-env:
	@sh scripts/check-env.sh

# format-check verifies formatting is canonical (Pint, PSR-12 based); lint runs
# PHPStan/Larastan static analysis. Kept as separate targets so a red one is
# obvious.
format-check:
	vendor/bin/pint --test

lint:
	vendor/bin/phpstan analyse

format:
	vendor/bin/pint

test:
	vendor/bin/pest

build:
	composer install --no-dev --optimize-autoloader

serve:
	php artisan serve

install:
	composer install

clean:
	rm -rf vendor .phpunit.cache .pint.cache coverage.xml
