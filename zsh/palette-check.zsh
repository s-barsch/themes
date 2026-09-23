# palette-check -- is the terminal actually using the sbdark / sblight palette?
#
# Each row shows an ANSI slot swatch next to the exact truecolor it is
# supposed to be, for whichever appearance the shell is in. Matching pair =
# the theme is loaded. Different = your window still has the old palette, or
# the terminal and the shell disagree about light and dark; reload Ghostty
# (super+shift+r) or open a new window.
palette-check() {
  local -a rows=(
    "4:suggestion:folders"
    "6:fastmode:executables"
    "5:purple:symlinks"
    "8:subtle:name@host"
    "10:success:clean branch"
    "9:error:out of sync"
  )
  print "  appearance: $THEMES_LIVE\n"
  print "  slot  truecolor   what it is"
  local row slot token label REPLY
  for row in $rows; do
    slot=${row%%:*}; token=${${row#*:}%%:*}; label=${row##*:}
    _themes_rgb $CC[$token]
    printf '   \e[48;5;%sm    \e[0m  \e[48;2;%sm    \e[0m   %s %-11s %s\n' \
      "$slot" "$REPLY" "$CC[$token]" "$token" "$label"
  done
  print "\n  Left and right of each row must look identical."
}
