# palette

The colours everything here is built from. Generated from
`ghostty/themes/sbdark` and `zsh/palette.zsh`; those two files are the source
of truth, this is the readable version.

## Terminal

| | colour |
| --- | --- |
| background | `#000000` |
| foreground | `#ffffff` |
| cursor | `#dc2626` |
| selection | `#264f78` |

## ANSI slots

`ls` can only reach these, which is why slots 4, 5 and 6 carry the file colours.

| slot | colour | used for |
| --- | --- | --- |
| 0 | `#262626` | black |
| 1 | `#dc2626` | red |
| 2 | `#16a34a` | green |
| 3 | `#ca8a04` | yellow |
| 4 | `#b1b9f9` | folders in ls |
| 5 | `#827dbd` | symlinks in ls |
| 6 | `#ff7814` | executables in ls |
| 7 | `#999999` | inactive |
| 8 | `#505050` | subtle / dim text |
| 9 | `#ff6b80` | error |
| 10 | `#4eba65` | success |
| 11 | `#ffc107` | warning |
| 12 | `#93a5ff` | blue |
| 13 | `#af87ff` | purple |
| 14 | `#0891b2` | cyan |
| 15 | `#ffffff` | text |

## Shell tokens

The `$CC` map in `zsh/palette.zsh`, used by the prompt and the plugin styles.

| token | colour | notes |
| --- | --- | --- |
| `orange` | `#d77757` | the accent orange |
| `red` | `#dc2626` | red_FOR_SUBAGENTS_ONLY -- the cursor |
| `fastmode` | `#ff7814` | fastMode -- executables |
| `skill` | `#af87ff` | autoAccept / skill / merged |
| `bash` | `#fd5db1` | bashBorder |
| `suggestion` | `#b1b9f9` | suggestion / permission / remember -- folders |
| `shimmer` | `#cfd7ff` | permissionShimmer |
| `blue` | `#93a5ff` | periwinkle blue |
| `plan` | `#48968c` | planMode |
| `ide` | `#4782c8` | ide |
| `border` | `#888888` | promptBorder |
| `text` | `#ffffff` | text |
| `inactive` | `#999999` | inactive |
| `subtle` | `#505050` | subtle |
| `success` | `#4eba65` | success |
| `error` | `#ff6b80` | error |
| `warning` | `#ffc107` | warning |
| `cyan` | `#0891b2` | cyan_FOR_SUBAGENTS_ONLY -- symlinks |
