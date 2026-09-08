#!/usr/bin/env bash
#
# install.sh -- install or update this terminal styling on a machine.
#
# Re-running it is the update path. Every change is either a symlink or lives
# inside a marked block, so a second run replaces what the first one wrote
# instead of stacking up. uninstall.sh removes all of it again.
#
#   ./install.sh               install or update
#   ./install.sh --dry-run     show what would change, write nothing
#   ./install.sh --no-ghostty  leave the terminal config alone

set -euo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC="$HOME/.zshrc"
STAMP="$(date +%Y%m%d%H%M%S)"

# Written into .zshrc as $HOME/... rather than an absolute path.
case "$REPO" in
  "$HOME"/*) REPO_RC="\$HOME${REPO#$HOME}" ;;
  *)         REPO_RC="$REPO" ;;
esac
BEGIN="# >>> themes >>>"
END="# <<< themes <<<"

DRY=0
DO_GHOSTTY=1
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)    DRY=1 ;;
    --no-ghostty) DO_GHOSTTY=0 ;;
    -h|--help)    sed -n '3,12p' "$0" | sed 's/^#\{1,\} \{0,1\}//'; exit 0 ;;
    *)            printf 'unknown option: %s\n' "$1" >&2; exit 2 ;;
  esac
  shift
done

title() { printf '\n%s\n' "$*"; }
say()   { printf '  %s\n' "$*"; }
warn()  { printf '  ! %s\n' "$*" >&2; }
die()   { printf 'error: %s\n' "$*" >&2; exit 1; }
tilde() { printf '%s' "${1/#$HOME/~}"; }

# Everything below the block markers, with the block itself removed.
strip_block() { # strip_block <file> <begin> <end>
  awk -v b="$2" -v e="$3" 'index($0,b)==1{s=1} s==0{print} index($0,e)==1{s=0}' "$1"
}

drop_trailing_blanks() {
  awk 'NF{last=NR} {line[NR]=$0} END{for(i=1;i<=last;i++) print line[i]}'
}

# Replace (or add) our marked block at the end of a file.
write_block() { # write_block <file> <payload>
  local file="$1" payload="$2" tmp
  tmp="$(mktemp)"
  if [ -f "$file" ]; then
    strip_block "$file" "$BEGIN" "$END" | drop_trailing_blanks > "$tmp"
  else
    : > "$tmp"
  fi
  printf '\n%s\n%s\n' "$BEGIN" "$payload" >> "$tmp"
  printf '%s\n' "$END" >> "$tmp"
  if [ "$DRY" -eq 1 ]; then
    say "would write block into $(tilde "$file")"
    rm -f "$tmp"
    return
  fi
  [ -f "$file" ] && cp "$file" "$file.bak-$STAMP"
  mv "$tmp" "$file"
  say "block   $(tilde "$file")"
}

link() { # link <src> <dst>
  local src="$1" dst="$2"
  [ -e "$src" ] || die "missing $src"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    say "ok      $(tilde "$dst")"
    return
  fi
  if [ "$DRY" -eq 1 ]; then say "would link $(tilde "$dst")"; return; fi
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak-$STAMP"
    say "saved   $(tilde "$dst").bak-$STAMP"
  fi
  ln -sfn "$src" "$dst"
  say "link    $(tilde "$dst")"
}

# --- zsh --------------------------------------------------------------------
title "zsh"
[ -r "$REPO/zsh/init.zsh" ] || die "$REPO/zsh/init.zsh not found"

write_block "$ZSHRC" "# Managed by $(tilde "$REPO")/install.sh -- re-run to update, uninstall.sh to remove.
# Sourced last on purpose: it overrides plugin styles set earlier in this file.
[[ -r \"$REPO_RC/zsh/init.zsh\" ]] && source \"$REPO_RC/zsh/init.zsh\""

if [ "$DRY" -eq 0 ]; then
  if command -v zsh >/dev/null && ! zsh -n "$ZSHRC" 2>/dev/null; then
    cp "$ZSHRC.bak-$STAMP" "$ZSHRC"
    die "patched .zshrc failed zsh -n; restored from $ZSHRC.bak-$STAMP"
  fi
  say "checked zsh -n \$ZSHRC"
fi

for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  found=0
  for base in /opt/homebrew/share /usr/local/share /usr/share/zsh/plugins /usr/share; do
    [ -r "$base/$plugin/$plugin.zsh" ] && found=1 && break
  done
  [ "$found" -eq 1 ] || warn "$plugin not found -- install it (brew install $plugin)"
done

# --- ghostty ----------------------------------------------------------------
if [ "$DO_GHOSTTY" -eq 1 ]; then
  title "ghostty"
  if [ "$(uname -s)" = "Darwin" ]; then
    GDIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
  else
    GDIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
  fi
  XDIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"

  for theme in sbdark sblight; do
    link "$REPO/ghostty/themes/$theme" "$GDIR/themes/$theme"
    [ "$XDIR" = "$GDIR" ] || link "$REPO/ghostty/themes/$theme" "$XDIR/themes/$theme"
  done

  # Ghostty 1.3 reads config.ghostty; older builds read a file named config.
  GCFG="$GDIR/config.ghostty"
  [ -f "$GDIR/config" ] && [ ! -f "$GCFG" ] && GCFG="$GDIR/config"

  write_block "$GCFG" "# Managed by $(tilde "$REPO")/install.sh -- re-run to update, uninstall.sh to remove.
# Last block wins in Ghostty, so this overrides any theme set above.
theme = sbdark"

  if [ "$DRY" -eq 0 ] && command -v ghostty >/dev/null; then
    if ghostty +validate-config >/dev/null 2>&1; then
      say "checked ghostty +validate-config"
    else
      warn "ghostty +validate-config reported a problem -- run it to see the detail"
    fi
  fi
fi

title "done"
say "start a new shell:  exec zsh"
[ "$DO_GHOSTTY" -eq 1 ] && say "reload the terminal: super+shift+r in Ghostty"
say "check the palette:  palette-check"
printf '\n'
