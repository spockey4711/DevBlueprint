# Quality gate for a Java + Spring Boot (Gradle) project. `make check` runs the
# whole gate; CI calls the same Gradle tasks. Everything goes through the Gradle
# wrapper (./gradlew) so local, CI and teammates build with the pinned Gradle.
.PHONY: check validate-env lint format test build run clean

check: validate-env lint format-check test

# Enforce the environment contract: .env.example must stay in lockstep with
# .env.schema, and a real .env (if present) must satisfy every required key. This
# is stack-agnostic and always on - fill in the schema, not this target.
validate-env:
	@sh scripts/check-env.sh

# format-check verifies formatting is canonical (Spotless); lint runs Checkstyle
# over main + test sources. Kept as separate targets so a red one is obvious.
format-check:
	./gradlew spotlessCheck

lint:
	./gradlew checkstyleMain checkstyleTest

format:
	./gradlew spotlessApply

test:
	./gradlew test

build:
	./gradlew bootJar

run:
	./gradlew bootRun

clean:
	./gradlew clean
