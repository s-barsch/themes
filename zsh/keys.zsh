# keys.zsh -- a key for the completion that is not Tab.
#
# Two different things complete the line you are typing:
#
#   Tab        zsh's own completion system. Many candidates, so it needs a key
#              that cycles through them.
#   the ghost  zsh-autosuggestions' grey inline guess from history. One
#              string, so it only needs a key that says yes.
#
# The plugin binds no key of its own for the second one. It wraps existing
# movement widgets instead -- forward-char, end-of-line and the vi equivalents,
# listed in ZSH_AUTOSUGGEST_ACCEPT_WIDGETS -- which is why -> and ^E take the
# ghost and Tab never does. Reaching for -> mid-line is a stretch, so Shift-Tab
# accepts it as well: it sits next to Tab, and stock zsh leaves it unbound, so
# nothing is taken away. With no ghost on the line it does nothing, which is
# what Shift-Tab did here before.
#
# Only the main keymap is touched. While a Tab menu is open the menuselect
# keymap has the keyboard, so its own Shift-Tab is left alone.

(( $+functions[_zsh_autosuggest_start] )) || return 0

# kcbt is the terminal's own back-tab sequence; \e[Z is what the xterm-likes
# (Ghostty among them) send, kept as the fallback when terminfo has no entry.
zmodload -i zsh/terminfo
_themes_backtab=${terminfo[kcbt]:-$'\e[Z'}
bindkey -M emacs "$_themes_backtab" autosuggest-accept
bindkey -M viins "$_themes_backtab" autosuggest-accept
unset _themes_backtab
