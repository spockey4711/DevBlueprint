# Quality gate for a Ruby on Rails project. `make check` runs the whole gate; CI
# calls the same commands. The Ruby version is pinned in .ruby-version /
# .tool-versions and gems are locked in Gemfile.lock, so local, CI and teammates
# run the same toolchain.
.PHONY: check lint format test security run console migrate setup

check: lint security test

# rubocop (the rubocop-rails-omakase ruleset) owns both formatting and style/lint
# for Ruby - there is no separate formatter. `make format` autocorrects in place;
# `make lint` only checks and is what the gate and CI run.
lint:
	bundle exec rubocop

format:
	bundle exec rubocop --autocorrect

# Brakeman is a static security scanner for Rails - part of the gate so an
# injection or mass-assignment slip fails CI, not review.
security:
	bundle exec brakeman --quiet --no-pager

test:
	bundle exec rails test

run:
	bin/rails server

console:
	bin/rails console

migrate:
	bin/rails db:migrate

setup:
	bundle install
