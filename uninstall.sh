#!/usr/bin/env bash
#
# uninstall.sh -- undo what install.sh did.
#
# Removes the marked block from ~/.zshrc and from the Ghostty config, and
# removes the theme symlinks, but only the ones pointing into this repo.
# Backups install.sh made (*.bak-*) are left alone.
#
#   ./uninstall.sh            remove everything
#   ./uninstall.sh --dry-run  show what would be removed

set -euo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC="$HOME/.zshrc"
BEGIN="# >>> themes >>>"
END="# <<< themes <<<"

DRY=0
[ "${1:-}" = "--dry-run" ] && DRY=1

say()   { printf '  %s\n' "$*"; }
title() { printf '\n%s\n' "$*"; }
tilde() { printf '%s' "${1/#$HOME/~}"; }

drop_block() { # drop_block <file>
  local file="$1" tmp
  [ -f "$file" ] || return 0
  grep -qF "$BEGIN" "$file" || { say "no block in $(tilde "$file")"; return 0; }
  if [ "$DRY" -eq 1 ]; then say "would drop block from $(tilde "$file")"; return; fi
  tmp="$(mktemp)"
  awk -v b="$BEGIN" -v e="$END" 'index($0,b)==1{s=1} s==0{print} index($0,e)==1{s=0}' \
    "$file" > "$tmp"
  mv "$tmp" "$file"
  say "dropped block from $(tilde "$file")"
}

unlink_if_ours() { # unlink_if_ours <path>
  local p="$1" target
  [ -L "$p" ] || return 0
  target="$(readlink "$p")"
  case "$target" in
    "$REPO"/*) ;;
    *) say "left    $(tilde "$p") (not ours)"; return 0 ;;
  esac
  if [ "$DRY" -eq 1 ]; then say "would remove $(tilde "$p")"; return; fi
  rm "$p"
  say "removed $(tilde "$p")"
}

title "zsh"
drop_block "$ZSHRC"

title "ghostty"
if [ "$(uname -s)" = "Darwin" ]; then
  GDIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
else
  GDIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
fi
XDIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"

GCFG="$GDIR/config.ghostty"
[ -f "$GDIR/config" ] && [ ! -f "$GCFG" ] && GCFG="$GDIR/config"
drop_block "$GCFG"

for theme in sbdark sblight; do
  unlink_if_ours "$GDIR/themes/$theme"
  [ "$XDIR" = "$GDIR" ] || unlink_if_ours "$XDIR/themes/$theme"
done

title "done"
say "start a new shell:  exec zsh"
say "reload the terminal: super+shift+r in Ghostty"
printf '\n'
