# sbdark / sblight palette for zsh
#
# The same colours the sbdark and sblight terminal themes use; see
# reference/palette.md.
# init.zsh sources this after the zsh plugins so it can override their
# defaults, and before prompt.zsh so the prompt can read $CC.

# --- palette ---------------------------------------------------------------
# Two maps, one per macOS appearance, taken from the dark and light columns of
# Claude Code's own theme table. $CC always holds whichever one is live; every
# style below is derived from it in themes_apply, so nothing else needs to know
# which appearance it is.
typeset -gA CC CC_DARK CC_LIGHT
CC_DARK=(
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
  cyan        '#0891b2'   # cyan_FOR_SUBAGENTS_ONLY
  purple      '#827dbd'   # purple_FOR_SUBAGENTS_ONLY -- symlinks
  pipe        '#ca8a04'   # yellow_FOR_SUBAGENTS_ONLY -- named pipes
)
CC_LIGHT=(
  orange      '#d77757'
  red         '#dc2626'
  fastmode    '#ff6a00'
  skill       '#8700ff'
  bash        '#ff0087'
  suggestion  '#5769f7'
  shimmer     '#899bff'
  blue        '#5769f7'
  plan        '#006666'
  ide         '#4782c8'
  border      '#999999'
  text        '#000000'
  inactive    '#666666'
  subtle      '#afafaf'
  success     '#2c7a39'
  error       '#ab2b3f'
  warning     '#966c1e'
  cyan        '#0891b2'
  purple      '#827dbd'
  pipe        '#ca8a04'
)

# Which appearance is live: $THEMES_APPEARANCE if you set it (dark or light),
# else what macOS says, else dark. AppleInterfaceStyle is "Dark" in dark mode
# and absent in light mode, and it tracks the Auto setting too.
_themes_appearance() {
  case $THEMES_APPEARANCE in
    dark|light) REPLY=$THEMES_APPEARANCE; return ;;
  esac
  REPLY=dark
  [[ $OSTYPE == darwin* ]] || return
  [[ "$(command defaults read -g AppleInterfaceStyle 2>/dev/null)" == Dark ]] || REPLY=light
}

# "#d77757" -> "215;119;87", for the escape-sequence styles below.
_themes_rgb() {
  local h=${1#\#}
  REPLY="$((16#${h[1,2]}));$((16#${h[3,4]}));$((16#${h[5,6]}))"
}

# themes_apply [dark|light] -- load that palette into $CC and rebuild every
# style that reads it. With no argument it asks _themes_appearance.
themes_apply() {
  local REPLY
  if [[ -n $1 ]]; then REPLY=$1; else _themes_appearance; fi
  typeset -g THEMES_LIVE=$REPLY
  if [[ $REPLY == light ]]; then CC=("${(@kv)CC_LIGHT}"); else CC=("${(@kv)CC_DARK}"); fi

  # --- autosuggestions ------------------------------------------------------
  # Not typed text, so it stays dim rather than full-strength.
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=$CC[subtle]"

  # --- syntax highlighting --------------------------------------------------
  # The input line is plain text by default. The one thing that gets a colour
  # is the command word, and only once zsh has actually resolved it: a command
  # that exists turns fastMode orange -- the same colour ls gives executables,
  # so a name means the same thing whether you are reading it or running it.
  #
  # Nothing turns red. A command that does not exist stays plain and simply
  # never lights up, which is the tell: you are typing and it is not going
  # orange. Mistyped names look unfinished rather than wrong.
  typeset -gA ZSH_HIGHLIGHT_STYLES
  local s
  for s in default reserved-word commandseparator autodirectory path \
           path_pathseparator path_prefix path_prefix_pathseparator globbing \
           history-expansion single-hyphen-option double-hyphen-option \
           back-quoted-argument back-quoted-argument-delimiter \
           single-quoted-argument double-quoted-argument \
           dollar-quoted-argument rc-quote dollar-double-quoted-argument \
           back-double-quoted-argument assign named-fd numeric-fd \
           redirection comment arithmetic-expansion bracket-level-1 \
           bracket-level-2 bracket-level-3 bracket-level-4 bracket-level-5; do
    ZSH_HIGHLIGHT_STYLES[$s]="fg=$CC[text]"
  done

  # Resolved to something real: an executable on PATH, a builtin, a function,
  # an alias, or a precommand like sudo. All of them are "found", so all of
  # them get the executable colour.
  for s in command builtin function alias suffix-alias global-alias \
           hashed-command precommand arg0; do
    ZSH_HIGHLIGHT_STYLES[$s]="fg=$CC[fastmode]"
  done

  # Not found -- deliberately indistinguishable from the rest of the line.
  ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=$CC[text]"
  ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]="standout"

  # --- ls, completion, grep -------------------------------------------------
  # di folders suggestion, ex executables fastMode, ln symlinks purple.
  # Also read by zsh completion listings, which speak truecolor either way.
  local di ln so pi ex dev fg bg ok sub ina ora
  _themes_rgb $CC[suggestion]; di=$REPLY
  _themes_rgb $CC[purple];     ln=$REPLY
  _themes_rgb $CC[skill];      so=$REPLY
  _themes_rgb $CC[pipe];       pi=$REPLY
  _themes_rgb $CC[fastmode];   ex=$REPLY
  _themes_rgb '#ffc107';       dev=$REPLY   # warning amber, legible on both
  _themes_rgb $CC_DARK[text];  fg=$REPLY
  _themes_rgb $CC_LIGHT[text]; bg=$REPLY
  _themes_rgb '#16a34a';       ok=$REPLY    # green_FOR_SUBAGENTS_ONLY
  export LS_COLORS="di=38;2;${di}:ln=38;2;${ln}:so=38;2;${so}:pi=38;2;${pi}:ex=38;2;${ex}:bd=38;2;${dev}:cd=38;2;${dev}:su=38;2;${fg};48;2;220;38;38:sg=38;2;${bg};48;2;${dev}:tw=38;2;${bg};48;2;${ok}:ow=38;2;${di};48;2;${ok}"
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
  zstyle ':completion:*:descriptions' format "%F{$CC[inactive]}%d%f"
  zstyle ':completion:*:warnings' format "%F{$CC[error]}no matches%f"

  _themes_rgb $CC[orange];   ora=$REPLY
  _themes_rgb $CC[inactive]; ina=$REPLY
  _themes_rgb $CC[subtle];   sub=$REPLY
  export GREP_COLORS="mt=1;38;2;${ora}:fn=38;2;${di}:ln=38;2;${ina}:se=38;2;${sub}"

  # The prompt bakes colours into its strings; let it rebuild them.
  (( $+functions[bureau_colours] )) && bureau_colours
  return 0
}

# Before every prompt, follow the appearance if it has changed. Registered
# here, ahead of prompt.zsh's hook, so the prompt draws in the new colours.
_themes_precmd() {
  local REPLY
  _themes_appearance
  [[ $REPLY == $THEMES_LIVE ]] || themes_apply $REPLY
}
autoload -U add-zsh-hook
add-zsh-hook precmd _themes_precmd

# --- ls -----------------------------------------------------------------------
# With coreutils installed, gls reads the truecolor LS_COLORS above and gets
# the exact hex values -- no dependence on the terminal palette at all. This
# alias supersedes the plain `alias ls='ls -G'` earlier in .zshrc.
#
# Without coreutils we fall back to BSD ls, which only speaks the 8 base ANSI
# slots, so the Ghostty themes have to carry the colours -- sbdark and sblight
# both put folders on slot 4, symlinks on 5 and executables on 6. That is why
# LSCOLORS asks for the plain letters e/g/f -- the bold ones E/G land on slots
# 12/14, which are different colours.
export CLICOLOR=1
#          dir ln so pi ex bd cd su sg tw ow
export LSCOLORS='exfxFxdxgxDxDxhbadacec'

if (( $+commands[gls] )); then
  alias ls='gls --color=auto'
else
  alias ls='ls -G'
fi

themes_apply

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
