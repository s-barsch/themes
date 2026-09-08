# prompt.zsh -- a bureau-derived zsh prompt
#
# Fork of oh-my-zsh's bureau theme, rewritten to read the $CC palette that
# palette.zsh defines. It stands alone: the git segment, the precmd and the
# PROMPT below are all defined here, so stock bureau is not needed at all.
#
# What changed from stock bureau:
#   - no clock on the top line, no nvm/node segment on the right
#   - no ± ✓ ● ▴ ▾ ⇅ ✹ symbols; the git segment is [branch 1↓ ~]
#   - 1↑ / 1↓ show how far ahead of / behind the upstream the branch is
#   - ~ marks a dirty tree (staged, unstaged or untracked)
#   - off the base branch, a second bracket appears when the base has moved
#     on without you: [feature 1↑] [main 3↓] -- time to rebase
#   - the ~ is always warning amber; it is the thing carrying the "you have
#     uncommitted work" signal, so the branch name does not have to
#   - branch name is not bold, and is coloured by state:
#       success = clean and in sync
#       text    = uncommitted changes, but nothing to push or pull -- plain
#                 white, because the amber ~ next to it already says it
#       error   = out of sync -- ahead of or behind the upstream, or the
#                 base branch has moved on. Out of sync outranks dirty:
#                 messy work in your tree is normal, drift from the
#                 remote is the thing worth a red light.
#   - the $ is a %
#
# Colours come from $CC (palette.zsh); the literals are the same
# values, kept as fallbacks so the theme also works if the palette is absent.

_BUREAU_OK="${CC[success]:-#4eba65}"       # success -- clean and in sync
_BUREAU_WARN="${CC[warning]:-#ffc107}"     # warning -- uncommitted changes
_BUREAU_OFF="${CC[error]:-#ff6b80}"        # error -- out of sync with a remote
_BUREAU_DIM="${CC[subtle]:-#505050}"       # the brackets
_BUREAU_TEXT="${CC[text]:-#ffffff}"        # the line you type on
_BUREAU_PATH="${CC[suggestion]:-#b1b9f9}"  # the working directory
_BUREAU_ERR="${CC[error]:-#ff6b80}"        # root

### Git [feature 1↑ ~] [main 3↓]

# The branch this repo is really built on: whatever origin/HEAD points at,
# falling back to the usual names for a repo that has never had it set.
# Returned as a remote ref (origin/main) so it tracks the last fetch, not
# whatever state a stale local main happens to be in.
#
# Cached per directory for the life of the shell -- it costs a git call and
# changes about never. Set origin/HEAD on a repo you already have a tab open
# in and that tab keeps the old answer until it is restarted.
typeset -gA _BUREAU_BASE_CACHE

_bureau_base_ref() {
  local key="$PWD" ref candidate

  if (( ${+_BUREAU_BASE_CACHE[$key]} )); then
    [[ -n "$_BUREAU_BASE_CACHE[$key]" ]] || return 1
    print -r -- "$_BUREAU_BASE_CACHE[$key]"
    return 0
  fi

  ref="$(command git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)"
  if [[ -z "$ref" ]]; then
    for candidate in origin/main origin/master main master; do
      if command git rev-parse --verify --quiet "$candidate" >/dev/null; then
        ref="$candidate"
        break
      fi
    done
  fi

  _BUREAU_BASE_CACHE[$key]="$ref"   # "" is a real answer: this repo has no base
  [[ -n "$ref" ]] || return 1
  print -r -- "$ref"
}

bureau_git_prompt() {
  # git status doubles as the "are we in a repo at all" check, so there is no
  # separate rev-parse. Non-git folders fail here and print nothing.
  local status_out
  status_out="$(command git status --porcelain -b 2>/dev/null)" || return
  [[ "$(command git config --get oh-my-zsh.hide-info 2>/dev/null)" == 1 ]] && return

  local -a lines=("${(@f)status_out}")
  local branchline="${lines[1]}" branch

  # "## main...origin/main [ahead 1, behind 2]" -> "main"
  if [[ "$branchline" == *"(no branch)"* ]]; then
    branch="$(command git rev-parse --short HEAD 2>/dev/null)" || return
  else
    branch="${branchline#\#\# }"
    branch="${branch#No commits yet on }"
    branch="${branch%%...*}"
    branch="${branch%% *}"
  fi

  local ahead=0 behind=0 dirty=0
  [[ "$branchline" =~ 'ahead ([0-9]+)' ]]  && ahead=$match[1]
  [[ "$branchline" =~ 'behind ([0-9]+)' ]] && behind=$match[1]
  (( ${#lines} > 1 )) && dirty=1

  # How far the base branch has run ahead of us. Skipped when we are on it.
  local base base_name behind_base=0
  if base="$(_bureau_base_ref)"; then
    base_name="${base##*/}"
    if [[ "$branch" != "$base_name" ]]; then
      behind_base="$(command git rev-list --count HEAD.."$base" 2>/dev/null)" || behind_base=0
    fi
  fi

  # Escalating, in order: dirty drops the green, drift from a remote goes red.
  # The ~ keeps its own amber either way, so it reads even on a red branch.
  local colour="$_BUREAU_OK"
  (( dirty )) && colour="$_BUREAU_TEXT"
  (( ahead || behind || behind_base )) && colour="$_BUREAU_OFF"

  local inner="%F{$colour}${branch:gs/%/%%}"   # a % in a branch is not an escape
  (( ahead ))  && inner+=" ${ahead}↑"
  (( behind )) && inner+=" ${behind}↓"
  inner+="%f"
  (( dirty ))  && inner+=" %F{$_BUREAU_WARN}~%f"

  local out="%F{$_BUREAU_DIM}[%f${inner}%F{$_BUREAU_DIM}]%f"
  (( behind_base )) && \
    out+=" %F{$_BUREAU_DIM}[%f%F{$colour}${base_name:gs/%/%%} ${behind_base}↓%f%F{$_BUREAU_DIM}]%f"

  print -n "$out"
}

### Prompt

if (( EUID == 0 )); then
  _USERNAME="%B%F{$_BUREAU_ERR}%n@%m%f%b"
  _LIBERTY="%F{$_BUREAU_ERR}#%f"
else
  _USERNAME="%F{$_BUREAU_DIM}%n@%m%f"
  _LIBERTY="%F{$_BUREAU_TEXT}%%%f"
fi
_PATH="%F{$_BUREAU_PATH}%~%f"

_1LEFT="$_USERNAME $_PATH"

bureau_precmd() {
  print
  print -rP "$_1LEFT"
}

setopt prompt_subst
PROMPT="%F{$_BUREAU_TEXT}>%f $_LIBERTY "
RPROMPT='$(bureau_git_prompt)'

autoload -U add-zsh-hook
add-zsh-hook precmd bureau_precmd
