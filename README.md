# themes

Terminal styling kept as one unit: a zsh prompt, a matching set of shell
colours, and a Ghostty theme so that the two agree.

```
name@host ~/code/themes                       [main 1↑ ~]
> ls
```

The prompt prints a context line, then a bare caret on the line you actually
type on. Everything you type stays in the plain text colour; a command turns
orange once zsh has found it.

It follows the Mac's appearance. In Dark mode everything is sbdark, in Light
mode sblight, and the colours come from the matching column of Claude Code's own
theme table. See [Light and dark](#light-and-dark).

## What is in here

| path | what it does |
| --- | --- |
| `zsh/init.zsh` | the single file `~/.zshrc` sources; loads the rest in order |
| `zsh/palette.zsh` | the `$CC` colour map (a dark and a light set), plus syntax-highlighting, autosuggestion, `ls`, completion and grep colours |
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
After pulling a change to the Ghostty side, re-run `./install.sh` too: the
theme line sits in Ghostty's config, not in the repo.

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
and the rest matches (`sblight` for a light terminal, with
`THEMES_APPEARANCE=light`).

## The git segment

```
name@host ~/code/sacer                  [feature 1↑ ~] [main 3↓]
```

The first bracket is where you are: the branch, how far it is ahead of or
behind its upstream, and a `~` if the tree is dirty. The second appears only
when you are off the base branch and the base has moved on without you — time
to rebase. Green is clean and in sync, the plain text colour means uncommitted
work, red means you have drifted from a remote.

Those counts are read from `refs/remotes/origin/*`, and **nothing in git
refreshes those on its own** — left alone, `[main 3↓]` would only ever be as
true as your last `git fetch`. So the prompt fetches for itself: at most once
every five minutes it kicks off a detached `git fetch --prune` and carries
straight on drawing. It never blocks, never holds the terminal, and never
prompts for credentials; a fetch that lands shows up on the *next* prompt.

Set `_BUREAU_FETCH_INTERVAL` in `~/.zshrc`, ahead of the `init.zsh` block, to
change the interval — or to `0` to switch the fetching off and go back to
counts that move only when you fetch by hand.

`git maintenance start` will not do this job, incidentally: its prefetch task
deliberately writes to `refs/prefetch/remotes/origin/*` and leaves the
remote-tracking refs alone, so the prompt would never see a thing it fetched.

## Light and dark

Ghostty is set to `theme = light:sblight,dark:sbdark`, so the terminal
switches with macOS by itself. The shell cannot: the prompt, the
syntax-highlighting and `LS_COLORS` are written as truecolor escapes, not as
palette slots. So before each prompt, `palette.zsh` asks macOS which appearance
is on (`defaults read -g AppleInterfaceStyle`, a few milliseconds). If it has
changed, `themes_apply` loads the other half of the palette and rebuilds
everything that reads `$CC`.

What that means in use: switch the Mac to Light and the terminal changes at
once. The prompt changes at the next prompt, which one Return gets you. Lines
already on screen keep the colours they were printed in.

The two sets are the `dark` and `light` columns of Claude Code's theme table,
token for token. The ANSI slots mean the same thing in both terminal themes: 4
is folders, 5 is symlinks, 6 is executables, 8 is dim, 9/10/11 are
error/success/warning, 15 is text. So BSD `ls` is correct in both too.

To pin one side, whatever macOS says (a terminal without appearance support,
Linux, a screenshot), set this in `~/.zshrc` ahead of the `init.zsh` block:

```sh
THEMES_APPEARANCE=light   # or dark
```

`themes_apply light` / `themes_apply dark` switches the current shell by hand.
Off macOS it is dark unless you set `THEMES_APPEARANCE`.

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
