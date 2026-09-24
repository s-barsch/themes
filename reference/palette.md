# palette

The colours everything here is built from. Generated from
`ghostty/themes/sbdark`, `ghostty/themes/sblight` and `zsh/palette.zsh`; those
files are the source of truth, this is the readable version. The dark and light
columns are the `dark` and `light` columns of Claude Code's theme table.

## Terminal

| | dark | light |
| --- | --- | --- |
| background | `#000000` | `#ffffff` |
| foreground | `#ffffff` | `#000000` |
| cursor | `#dc2626` | `#dc2626` |
| selection | `#264f78` | `#b4d5ff` |

## ANSI slots

`ls` can only reach these, which is why slots 4, 5 and 6 carry the file colours.
A slot means the same thing in both themes.

| slot | dark | light | used for |
| --- | --- | --- | --- |
| 0 | `#262626` | `#f5f5f5` | surface |
| 1 | `#dc2626` | `#dc2626` | red |
| 2 | `#16a34a` | `#16a34a` | green |
| 3 | `#ca8a04` | `#ca8a04` | yellow |
| 4 | `#b1b9f9` | `#5769f7` | folders in ls |
| 5 | `#827dbd` | `#827dbd` | symlinks in ls |
| 6 | `#ff7814` | `#ff6a00` | executables in ls |
| 7 | `#999999` | `#666666` | inactive |
| 8 | `#505050` | `#afafaf` | subtle / dim text |
| 9 | `#ff6b80` | `#ab2b3f` | error |
| 10 | `#4eba65` | `#2c7a39` | success |
| 11 | `#ffc107` | `#966c1e` | warning |
| 12 | `#93a5ff` | `#5769f7` | blue |
| 13 | `#af87ff` | `#8700ff` | purple |
| 14 | `#0891b2` | `#0891b2` | cyan |
| 15 | `#ffffff` | `#000000` | text |

## Shell tokens

The `$CC` map in `zsh/palette.zsh`, used by the prompt and the plugin styles.
`$CC` holds the dark or the light set, following the Mac's appearance.

| token | dark | light | notes |
| --- | --- | --- | --- |
| `orange` | `#d77757` | `#d77757` | the accent orange |
| `red` | `#dc2626` | `#dc2626` | red_FOR_SUBAGENTS_ONLY -- the cursor |
| `fastmode` | `#ff7814` | `#ff6a00` | fastMode -- executables |
| `skill` | `#af87ff` | `#8700ff` | autoAccept / skill / merged |
| `bash` | `#fd5db1` | `#ff0087` | bashBorder |
| `suggestion` | `#b1b9f9` | `#5769f7` | suggestion / permission / remember -- folders |
| `shimmer` | `#cfd7ff` | `#899bff` | permissionShimmer |
| `blue` | `#93a5ff` | `#5769f7` | periwinkle blue |
| `plan` | `#48968c` | `#006666` | planMode |
| `ide` | `#4782c8` | `#4782c8` | ide |
| `border` | `#888888` | `#999999` | promptBorder |
| `text` | `#ffffff` | `#000000` | text |
| `inactive` | `#999999` | `#666666` | inactive |
| `subtle` | `#505050` | `#afafaf` | subtle |
| `success` | `#4eba65` | `#2c7a39` | success |
| `error` | `#ff6b80` | `#ab2b3f` | error |
| `warning` | `#ffc107` | `#966c1e` | warning |
| `cyan` | `#0891b2` | `#0891b2` | cyan_FOR_SUBAGENTS_ONLY |
| `purple` | `#827dbd` | `#827dbd` | purple_FOR_SUBAGENTS_ONLY -- symlinks |
| `pipe` | `#ca8a04` | `#ca8a04` | yellow_FOR_SUBAGENTS_ONLY -- named pipes |
