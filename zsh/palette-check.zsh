# palette-check -- is the terminal actually using the sbdark palette?
#
# Each row shows an ANSI slot swatch next to the exact truecolor it is
# supposed to be. Matching pair = the theme is loaded. Different = your
# window still has the old palette; reload Ghostty (super+shift+r) or open
# a new window.
palette-check() {
  local -a rows=(
    "4:177;185;249:#b1b9f9 suggestion  folders"
    "6:255;120;20:#ff7814 fastMode     executables"
    "5:130;125;189:#827dbd purple      symlinks"
    "8:80;80;80:#505050 subtle      name@host"
    "10:78;186;101:#4eba65 success     clean branch"
    "9:255;107;128:#ff6b80 error       dirty branch"
  )
  print "  slot  truecolor   what it is"
  local row slot rgb label
  for row in $rows; do
    slot="${row%%:*}"; rgb="${${row#*:}%%:*}"; label="${row##*:}"
    printf '   \e[48;5;%sm    \e[0m  \e[48;2;%sm    \e[0m   %s\n' "$slot" "$rgb" "$label"
  done
  print "\n  Left and right of each row must look identical."
}
