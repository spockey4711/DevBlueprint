class Devblueprint < Formula
  desc "Documentation-first engineering-setup kit (git workflow + quality gate + AI guidance)"
  homepage "https://github.com/spockey4711/DevBlueprint"
  url "https://github.com/spockey4711/DevBlueprint/archive/refs/tags/v0.1.0.tar.gz"
  # Replace with the sha256 of the release tarball above. Compute it with:
  #   curl -fsSL <url> | shasum -a 256
  # See packaging/homebrew/README.md for the full release runbook.
  sha256 "REPLACE_WITH_RELEASE_TARBALL_SHA256"
  license "MIT"

  def install
    # Ship the whole kit: bin/devblueprint resolves core/ and variants/ relative
    # to itself, so it must live next to them. Keep it out of the linked bin and
    # expose a wrapper instead.
    libexec.install Dir["*"]

    # A wrapper (not a symlink): the CLI derives its kit root from its own path
    # without following symlinks, so it must be run by its real libexec path.
    (bin/"devblueprint").write <<~SH
      #!/bin/bash
      exec "#{libexec}/bin/devblueprint" "$@"
    SH
    chmod 0755, bin/"devblueprint"
  end

  test do
    assert_match "devblueprint", shell_output("#{bin}/devblueprint version")
  end
end
