class Devblueprint < Formula
  desc "Documentation-first engineering-setup kit (git workflow + quality gate + AI guidance)"
  homepage "https://github.com/spockey4711/DevBlueprint"
  url "https://github.com/spockey4711/DevBlueprint/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "d6006b6fae81d601030aa5fb592738c803b4cb86cb797c743e496e1d6a4787dd"
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
