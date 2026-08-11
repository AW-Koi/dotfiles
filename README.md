# My Dotfiles (Windows)

Fish and starship on Windows, under msys2. Everything for Windows is under `windows/`.

This branch forks `main`, so the Arch directories (`hypr`, `waybar`, `kitty`, `shell`,
`fish`) are still checked out here and are ignored on Windows. Use `main` for the Arch
setup, where they're managed with stow.

The prompt is a green-phosphor terminal theme: three shades of green for normal
state, amber for anything that needs attention, and red when a command fails.

```
┌─ahwoouser@AHWOO-01 …/AhwooClient «task/brand-pages»  MOD:3  STG:1  NEW:2     11:42:44
└─▶
```

## Setup

- **OS**: Windows 11
- **Shell**: Fish, via [msys2](https://www.msys2.org/) (`pacman -S fish`)
- **Terminal**: mintty (ships with msys2)
- **Prompt**: Starship

## Structure

```
dotfiles/
├── windows/
│   ├── install.ps1                                  # copies configs into place
│   ├── starship/.config/starship.toml               # prompt theme
│   ├── fish/.config/fish/config.fish                # greeting off, starship init
│   ├── fish/.config/fish/functions/fish_title.fish  # terminal tab text
│   └── terminal/                                    # tab icon + its generator
└── hypr/ waybar/ kitty/ shell/ fish/                # Arch config, from main
```

The `package/.config/...` nesting mirrors the stow layout on `main` so both branches
read the same way, but nothing is symlinked here. `install.ps1` copies, because stow
needs symlink privileges Windows doesn't hand out by default.

## Install

```powershell
git clone -b windows https://github.com/AW-Koi/dotfiles.git $HOME\dotfiles
cd $HOME\dotfiles\windows
.\install.ps1
```

Pass `-WhatIf` first to see what it would touch without writing anything. Any file it
replaces is copied to `*.backup` alongside the original.

The script finds every fish installation it can (msys2, cygwin, whatever is on PATH),
asks each one where it reads config from, and installs there. If fish or starship is
missing it prints the command to install it.

To add a fish that lives somewhere unusual:

```powershell
.\install.ps1 -FishPath 'D:\tools\fish\bin\fish.exe'
```

## Where things land

| Repo file | Destination |
| --- | --- |
| `windows/starship/.config/starship.toml` | `%USERPROFILE%\.config\starship.toml` |
| everything under `windows/fish/.config/fish/` | whatever `$__fish_config_dir` reports, per fish install |

## Windows Terminal

The tab title comes from `fish_title`, which prints the current directory's name.
Fish's default prints `prompt_pwd`, which renders as `/c/A/D/AhwooClient` and is
illegible at tab width.

The tab icon is `terminal/fish.png`, drawn to match the prompt. To point the fish
profile at it:

```powershell
.\install.ps1 -UpdateWindowsTerminal
```

That rewrites `icon` on any profile whose name or command line mentions fish, backing
up `settings.json` first. It stores an absolute path, so keep the repo somewhere
permanent (`%USERPROFILE%\dotfiles`) rather than a temp directory.

`terminal/generate-icon.ps1` redraws the PNG from GDI+ primitives if you want to
change the colours or the shape.

## Where fish reads its config

Fish on Windows may not read `~/.config/fish/config.fish` where you expect. msys2
decides what `$HOME` means from `db_home` in `/etc/nsswitch.conf`. The desktop is set
to `db_home: windows cygwin desc`, so `$HOME` is `C:\Users\<user>` and fish reads
`C:\Users\<user>\.config\fish\config.fish`, not `C:\msys64\home\<user>\...`. A default
msys2 install does the opposite. Cygwin's fish is separate again, with its own home
under `C:\cygwin64\home\<user>`.

If a config seems to be ignored, ask fish where it actually looks:

```fish
echo $__fish_config_dir
```

`install.ps1` does this rather than hardcoding paths, so it lands correctly either way.

`config.fish` sets `STARSHIP_CONFIG` explicitly for a related reason. `starship.exe`
is a native Windows binary and doesn't resolve the POSIX `$HOME` that fish hands it,
so cygwin's fish would otherwise look for a config in its own home and find nothing.

Line endings are pinned to LF in `windows/.gitattributes`. Fish parses a trailing CR
as part of the token, so a CRLF checkout of `config.fish` breaks the shell.

## Reading the prompt

Git status spells each state out rather than encoding it in a symbol, since an
abstract glyph can't tell you whether it means untracked or unstaged. Each label
also gets its own colour.

| Label | Meaning | Colour |
| --- | --- | --- |
| `MOD:3` | modified | amber |
| `STG:1` | staged | green |
| `NEW:2` | untracked | blue |
| `DEL:1` | deleted | red |
| `MV:1` | renamed | purple |
| `CONFLICT:1` | conflicted | bold red |
| `STASH:2` | stashed | pale green |
| `↑2` `↓1` | ahead of, behind upstream | blue |

Arrows are the only symbols left, because a direction needs no legend.

Everything else on the line:

| Element | Meaning |
| --- | --- |
| `«branch»` | current branch |
| `+4s` | last command's runtime, shown past 2s only |
| red `─▶` | last command exited non-zero |
| `NODE` / `NET` | only appear in directories with those projects |

## Fonts

Everything renders in stock DejaVu Sans Mono, which mintty ships with, so you don't
need a Nerd Font here. The `main` config does use Nerd Font glyphs throughout. If you
want the icon versions, take the symbols from `shell/.config/starship.toml` on `main`.

Keeping that true constrains which glyphs the prompt can use. Box Drawing, Latin-1,
Arrows (U+21xx), and Mathematical Operators (U+22xx) are all covered. Dingbats
(`✓`, `✘`) and the U+27Ex angle brackets are not, and mintty silently substitutes them
from another font at a different width, which shifts the rest of the line. If you
swap a glyph, pick one from a covered block.
