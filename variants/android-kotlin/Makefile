# Quality gate for an Android (Kotlin + Gradle) project. `make check` runs the
# whole gate; CI calls the same Gradle tasks. Everything goes through the Gradle
# wrapper (./gradlew) so local, CI and teammates build with the pinned Gradle.
.PHONY: check lint format detekt androidlint test build clean

check: lint detekt androidlint test

lint:
	./gradlew ktlintCheck

format:
	./gradlew ktlintFormat

detekt:
	./gradlew detekt

androidlint:
	./gradlew lintDebug

test:
	./gradlew testDebugUnitTest

build:
	./gradlew assembleDebug

clean:
	./gradlew clean
