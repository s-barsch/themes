# themes

Terminal styling kept as one unit: a zsh prompt, a matching set of shell
colours, and a Ghostty theme so that the two agree.

```
name@host ~/code/themes                       [main 1↑ ~]
> ls
```

The prompt prints a context line, then a bare white caret on the line you
actually type on. Everything you type stays white; only a command that does
not exist turns red.

## What is in here

| path | what it does |
| --- | --- |
| `zsh/init.zsh` | the single file `~/.zshrc` sources; loads the rest in order |
| `zsh/palette.zsh` | the `$CC` colour map, plus syntax-highlighting, autosuggestion, `ls`, completion and grep colours |
| `zsh/prompt.zsh` | the prompt: context line, git segment, caret |
| `zsh/palette-check.zsh` | `palette-check`, a command that shows whether the terminal really has the palette |
| `ghostty/themes/sbdark` | the dark terminal theme (background, cursor, 16 palette slots) |
| `ghostty/themes/sblight` | the light counterpart, for `theme = light:sblight,dark:sbdark` |
| `reference/palette.md` | every colour in one table, generated from the files above |

## Install

```sh
git clone <this repo> ~/code/themes
cd ~/code/themes
./install.sh
exec zsh
```

Then reload the terminal (super+shift+r in Ghostty) so it picks up the theme.

`install.sh` writes one marked block into `~/.zshrc`, one into the Ghostty
config, and symlinks the two theme files into Ghostty's theme directories. It
backs up any file it rewrites as `<file>.bak-<timestamp>`, and it is safe to
run repeatedly.

| command | effect |
| --- | --- |
| `./install.sh` | install, or update after a `git pull` |
| `./install.sh --dry-run` | print what would change, write nothing |
| `./install.sh --no-ghostty` | shell only, leave the terminal config alone |
| `./uninstall.sh` | remove the blocks and the symlinks again |

The zsh side is sourced straight out of the repo, so after the first install a
`git pull` is the whole update: the next shell picks the changes up. Keep the
repo somewhere permanent — if you move it, re-run `install.sh` to repoint the
`~/.zshrc` block and the theme symlinks.

## Requirements

- zsh 5.7 or newer, for `%F{#rrggbb}` truecolor prompt escapes
- a truecolor terminal (`COLORTERM=truecolor`)
- optional: `zsh-autosuggestions` and `zsh-syntax-highlighting`. `init.zsh`
  sources them if your rc has not already, and `install.sh` warns if they are
  missing.

Ghostty is the terminal this is tuned for, but only `ghostty/` is
Ghostty-specific. `./install.sh --no-ghostty` gives you the shell styling on
any terminal; set the 16 palette slots by hand from `ghostty/themes/sbdark`
and the rest matches.

## How the colours map

Prompt colours are emitted as literal truecolor escapes, so they appear as soon
as a new shell starts. `ls` is different: BSD `ls` on macOS can only speak the
eight base ANSI colours, so it emits `\e[34m` for a folder and `\e[36m` for an
executable and the *terminal* decides what those mean. That is why the theme
pins palette slot 4 to the folder colour and slot 6 to the executable colour.

The practical consequence: prompt changes show up after `exec zsh`, but `ls`
colours need the terminal to reload its theme. If folders and scripts look
wrong, run `palette-check` — it prints each ANSI slot next to the exact colour
it should be, so a mismatch tells you the terminal has not reloaded.

Installing GNU coreutils and using `gls --color=auto` sidesteps this entirely:
GNU `ls` honours the truecolor `LS_COLORS` that `palette.zsh` already sets.
