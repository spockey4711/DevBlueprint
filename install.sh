#!/bin/sh
# install.sh - install DevBlueprint without cloning the repo.
#
#   curl -fsSL https://raw.githubusercontent.com/spockey4711/DevBlueprint/master/install.sh | sh
#
# It downloads the whole kit (bin/ core/ variants/ scripts/ VERSION) into a
# prefix directory and writes a small wrapper onto your PATH that execs the real
# CLI. A wrapper - not a symlink - is deliberate: bin/devblueprint resolves its
# kit root from ${BASH_SOURCE[0]} without following symlinks, so it must be run
# by its real path for core/ and variants/ to resolve.
#
# Configure via environment variables (all optional):
#   DEVBLUEPRINT_PREFIX   where the kit lands        (default: $HOME/.devblueprint)
#   DEVBLUEPRINT_BIN      where the wrapper lands     (default: $HOME/.local/bin)
#   DEVBLUEPRINT_VERSION  git ref to install          (default: master)
#   DEVBLUEPRINT_SRC      local kit dir to copy from  (default: download from GitHub)
set -eu

REPO="spockey4711/DevBlueprint"
PREFIX="${DEVBLUEPRINT_PREFIX:-$HOME/.devblueprint}"
BINDIR="${DEVBLUEPRINT_BIN:-$HOME/.local/bin}"
REF="${DEVBLUEPRINT_VERSION:-master}"
SRC="${DEVBLUEPRINT_SRC:-}"

say() { printf '%s\n' "$*"; }
die() { printf 'install: %s\n' "$*" >&2; exit 1; }

# --- fetch the kit into a fresh $PREFIX --------------------------------------
rm -rf "$PREFIX"
mkdir -p "$PREFIX"

if [ -n "$SRC" ]; then
  # Local source: copy the kit as-is (used for development and offline testing).
  [ -d "$SRC" ] || die "DEVBLUEPRINT_SRC=$SRC is not a directory"
  say "Copying DevBlueprint from $SRC ..."
  # Copy the directory contents (including dotfiles) into $PREFIX.
  tar -C "$SRC" -cf - . | tar -C "$PREFIX" -xf -
else
  url="https://github.com/$REPO/archive/refs/heads/$REF.tar.gz"
  say "Downloading DevBlueprint ($REF) from $url ..."
  if command -v curl >/dev/null 2>&1; then
    fetch() { curl -fsSL "$1"; }
  elif command -v wget >/dev/null 2>&1; then
    fetch() { wget -qO- "$1"; }
  else
    die "need curl or wget to download DevBlueprint"
  fi
  command -v tar >/dev/null 2>&1 || die "need tar to unpack DevBlueprint"
  # --strip-components=1 drops the GitHub "DevBlueprint-<ref>/" top-level dir.
  fetch "$url" | tar -xz --strip-components=1 -C "$PREFIX" \
    || die "download or extraction failed (is ref '$REF' valid?)"
fi

[ -x "$PREFIX/bin/devblueprint" ] || die "installed kit is missing bin/devblueprint"

# --- write the PATH wrapper (execs the real CLI by its real path) ------------
mkdir -p "$BINDIR"
wrapper="$BINDIR/devblueprint"
cat > "$wrapper" <<EOF
#!/bin/sh
exec "$PREFIX/bin/devblueprint" "\$@"
EOF
chmod 0755 "$wrapper"

say ""
say "Installed:"
say "  kit     -> $PREFIX"
say "  command -> $wrapper"
say "  version -> $("$wrapper" version)"

# --- PATH hint ---------------------------------------------------------------
case ":$PATH:" in
  *":$BINDIR:"*) ;;
  *)
    say ""
    say "NOTE: $BINDIR is not on your PATH. Add it, e.g.:"
    say "  export PATH=\"$BINDIR:\$PATH\""
    ;;
esac

say ""
say "Try it:  devblueprint list"
