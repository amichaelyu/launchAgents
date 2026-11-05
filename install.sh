#!/bin/bash
# Install (or uninstall) the agents that aren't packaged with Homebrew.
#   ./install.sh audio-sleep-guard rex-ubuntu-vm
#   ./install.sh --uninstall rex-ubuntu-vm
# Each folder holds one executable and one LaunchAgent plist. The executable is
# symlinked into ~/.local/bin (so edits here take effect), and the plist is copied
# into ~/Library/LaunchAgents and loaded.
set -euo pipefail

cd "$(dirname "$0")"
BIN="$HOME/.local/bin"
AGENTS="$HOME/Library/LaunchAgents"
DOMAIN="gui/$(id -u)"

uninstall=false
if [ "${1:-}" = --uninstall ]; then uninstall=true; shift; fi
[ $# -gt 0 ] || { sed -n '2,7p' "$0"; exit 1; }

for name in "$@"; do
  dir="${name%/}"
  plist=$(ls "$dir"/*.plist 2>/dev/null | head -1)
  [ -n "$plist" ] || { echo "$dir: no plist (Homebrew-packaged agents install with brew)" >&2; exit 1; }
  label=$(plutil -extract Label raw "$plist")
  exe=$(plutil -extract ProgramArguments.0 raw "$plist")

  launchctl bootout "$DOMAIN/$label" 2>/dev/null || true
  if $uninstall; then
    rm -f "$AGENTS/$(basename "$plist")" "$exe"
    echo "removed $label"
    continue
  fi

  mkdir -p "$BIN" "$AGENTS"
  ln -sf "$PWD/$dir/$(basename "$exe")" "$exe"
  cp "$plist" "$AGENTS/"
  launchctl bootstrap "$DOMAIN" "$AGENTS/$(basename "$plist")"
  echo "installed $label"
done
