# init.zsh -- the single file ~/.zshrc sources.
#
# Order matters:
#   1. the plugins, if the rc has not already loaded them
#   2. palette.zsh, which overrides plugin styles, so it must follow them
#   3. prompt.zsh, which reads the $CC palette that palette.zsh defines
#
# Everything is sourced straight out of the repo, so editing a file here takes
# effect in the next shell -- there is nothing to reinstall after a git pull.

_themes_dir=${0:A:h}

# --- plugins ----------------------------------------------------------------
# Only if the rc has not loaded them already; sourcing twice duplicates hooks.
_themes_plugin() {
  local name=$1 p
  for p in \
    /opt/homebrew/share/$name/$name.zsh \
    /usr/local/share/$name/$name.zsh \
    /usr/share/zsh/plugins/$name/$name.zsh \
    /usr/share/$name/$name.zsh
  do
    [[ -r $p ]] && { source $p; return 0 }
  done
  return 1
}

# zsh-autosuggestions sets no version variable, so probe a function instead.
(( $+functions[_zsh_autosuggest_start] )) || _themes_plugin zsh-autosuggestions
(( ${+ZSH_HIGHLIGHT_VERSION} ))           || _themes_plugin zsh-syntax-highlighting

# --- styling ----------------------------------------------------------------
source "$_themes_dir/palette.zsh"
source "$_themes_dir/prompt.zsh"
source "$_themes_dir/palette-check.zsh"

# GNU ls needs the flag spelled out; BSD ls reads $CLICOLOR, set in palette.zsh.
[[ $OSTYPE == linux* ]] && alias ls='ls --color=auto'

unfunction _themes_plugin
unset _themes_dir
