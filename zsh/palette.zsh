# sbdark palette for zsh
#
# The same colours the sbdark terminal theme uses; see reference/palette.md.
# init.zsh sources this after the zsh plugins so it can override their
# defaults, and before prompt.zsh so the prompt can read $CC.

# --- palette ---------------------------------------------------------------
typeset -gA CC
CC=(
  orange      '#d77757'   # the accent orange
  red         '#dc2626'   # red_FOR_SUBAGENTS_ONLY -- the cursor
  fastmode    '#ff7814'   # fastMode -- executables
  skill       '#af87ff'   # autoAccept / skill / merged
  bash        '#fd5db1'   # bashBorder
  suggestion  '#b1b9f9'   # suggestion / permission / remember -- folders
  shimmer     '#cfd7ff'   # permissionShimmer
  blue        '#93a5ff'   # periwinkle blue
  plan        '#48968c'   # planMode
  ide         '#4782c8'   # ide
  border      '#888888'   # promptBorder
  text        '#ffffff'   # text
  inactive    '#999999'   # inactive
  subtle      '#505050'   # subtle
  success     '#4eba65'   # success
  error       '#ff6b80'   # error
  warning     '#ffc107'   # warning
  cyan        '#0891b2'   # cyan_FOR_SUBAGENTS_ONLY -- symlinks
)

# --- prompt ------------------------------------------------------------------
# The prompt lives in prompt.zsh, sourced after this file so it can read the
# $CC palette above. Nothing prompt-related belongs here -- it would just be
# overridden.

# --- autosuggestions --------------------------------------------------------
# Not typed text, so it stays dim rather than white.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=$CC[subtle]"

# --- syntax highlighting ----------------------------------------------------
# The input line is white by default. The one thing that gets a colour is the
# command word, and only once zsh has actually resolved it: a command that
# exists turns fastMode orange -- the same colour ls gives executables, so a
# name means the same thing whether you are reading it or running it.
#
# Nothing turns red. A command that does not exist stays white and simply
# never lights up, which is the tell: you are typing and it is not going
# orange. Mistyped names look unfinished rather than wrong.
typeset -gA ZSH_HIGHLIGHT_STYLES
_s=""
for _s in default reserved-word commandseparator autodirectory path \
          path_pathseparator path_prefix path_prefix_pathseparator globbing \
          history-expansion single-hyphen-option double-hyphen-option \
          back-quoted-argument back-quoted-argument-delimiter \
          single-quoted-argument double-quoted-argument \
          dollar-quoted-argument rc-quote dollar-double-quoted-argument \
          back-double-quoted-argument assign named-fd numeric-fd \
          redirection comment arithmetic-expansion bracket-level-1 \
          bracket-level-2 bracket-level-3 bracket-level-4 bracket-level-5; do
  ZSH_HIGHLIGHT_STYLES[$_s]="fg=$CC[text]"
done

# Resolved to something real: an executable on PATH, a builtin, a function,
# an alias, or a precommand like sudo. All of them are "found", so all of
# them get the executable colour.
for _s in command builtin function alias suffix-alias global-alias \
          hashed-command precommand arg0; do
  ZSH_HIGHLIGHT_STYLES[$_s]="fg=$CC[fastmode]"
done
unset _s

# Not found -- deliberately indistinguishable from the rest of the line.
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=$CC[text]"
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]="standout"

# --- ls, completion, grep ---------------------------------------------------
# With coreutils installed, gls reads the truecolor LS_COLORS below and gets
# the exact hex values -- no dependence on the terminal palette at all. This
# alias supersedes the plain `alias ls='ls -G'` earlier in .zshrc.
#
# Without coreutils we fall back to BSD ls, which only speaks the 8 base ANSI
# slots, so the Ghostty theme has to carry the colours:
#   slot 4 (blue) = suggestion, 6 (cyan) = fastMode, 5 (magenta) = symlinks.
# That is why LSCOLORS asks for the plain letters e/g/f -- the bold ones E/G
# land on slots 12/14, which are different colours.
export CLICOLOR=1
#          dir ln so pi ex bd cd su sg tw ow
export LSCOLORS='exfxFxdxgxDxDxhbadacec'

if (( $+commands[gls] )); then
  alias ls='gls --color=auto'
else
  alias ls='ls -G'
fi

# di folders suggestion, ex executables fastMode, ln symlinks purple.
# Also read by zsh completion listings, which speak truecolor either way.
export LS_COLORS="di=38;2;177;185;249:ln=38;2;130;125;189:so=38;2;175;135;255:pi=38;2;202;138;4:ex=38;2;255;120;20:bd=38;2;255;193;7:cd=38;2;255;193;7:su=38;2;255;255;255;48;2;220;38;38:sg=38;2;0;0;0;48;2;255;193;7:tw=38;2;0;0;0;48;2;22;163;74:ow=38;2;177;185;249;48;2;22;163;74"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format "%F{$CC[inactive]}%d%f"
zstyle ':completion:*:warnings' format "%F{$CC[error]}no matches%f"

export GREP_COLORS='mt=1;38;2;215;119;87:fn=38;2;177;185;249:ln=38;2;153;153;153:se=38;2;80;80;80'

# --- preview helper ---------------------------------------------------------
# palette-show -- print the 16 terminal slots plus the named tokens.
palette-show() {
  local i name
  print -P "%F{$CC[inactive]}ANSI slots%f"
  for i in {0..15}; do
    printf '\e[48;5;%dm  \e[0m' $i
    (( (i + 1) % 8 )) || print
  done
  print -P "\n%F{$CC[inactive]}palette tokens%f"
  for name in ${(ok)CC}; do
    print -P "  %F{$CC[$name]}████%f $name %F{$CC[subtle]}$CC[$name]%f"
  done
}
