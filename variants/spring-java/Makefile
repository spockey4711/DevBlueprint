# Quality gate for a Java + Spring Boot (Gradle) project. `make check` runs the
# whole gate; CI calls the same Gradle tasks. Everything goes through the Gradle
# wrapper (./gradlew) so local, CI and teammates build with the pinned Gradle.
.PHONY: check lint format test build run clean

check: lint format-check test

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
