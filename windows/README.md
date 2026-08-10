# Windows setup

Fish + starship on Windows, as a companion to the Arch config on `main`. The prompt
is a green-phosphor terminal theme: three shades of green for normal state, amber for
anything that needs attention, and red when a command fails.

```
┌─ahwoouser@AHWOO-01 …/AhwooClient ⟨task/brand-pages⟩ ~3 +1 NODE v24.8.0        11:42:44
└─▶
```

## Setup

- **Shell**: Fish, via [msys2](https://www.msys2.org/) (`pacman -S fish`)
- **Prompt**: Starship
- **Terminal**: mintty (ships with msys2)

## Install

```powershell
git clone -b windows https://github.com/AW-Koi/dotfiles.git $HOME\dotfiles
cd $HOME\dotfiles\windows
.\install.ps1
```

Pass `-WhatIf` to see what it would touch without writing anything. Any file it
replaces is copied to `*.backup` alongside the original first.

The script finds every fish installation it can (msys2, cygwin, whatever is on
PATH), asks each one where it reads config from, and installs there. If fish or
starship is missing it tells you the command to install it.

To add a fish that lives somewhere unusual:

```powershell
.\install.ps1 -FishPath 'D:\tools\fish\bin\fish.exe'
```

## Where things land

| Repo file | Destination |
| --- | --- |
| `starship/.config/starship.toml` | `%USERPROFILE%\.config\starship.toml` |
| `fish/.config/fish/config.fish` | whatever `$__fish_config_dir` reports, per fish install |

Stow isn't used here, since it doesn't work on Windows without symlink privileges.
The `package/.config/...` layout matches `main` so the two branches read the same way.

## Where fish reads its config

Fish on Windows may not read `~/.config/fish/config.fish` where you expect. msys2
decides what `$HOME` means from `db_home` in `/etc/nsswitch.conf`. This machine is
set to `db_home: windows cygwin desc`, so `$HOME` is `C:\Users\<user>` and fish
reads `C:\Users\<user>\.config\fish\config.fish`, not `C:\msys64\home\<user>\...`.
A default msys2 install does the opposite.

If a config seems to be ignored, ask fish where it actually looks:

```fish
echo $__fish_config_dir
```

`install.ps1` does this rather than hardcoding paths, so it lands correctly either way.

`config.fish` sets `STARSHIP_CONFIG` explicitly for a related reason. `starship.exe`
is a native Windows binary and doesn't resolve the POSIX `$HOME` that fish hands it,
so cygwin's fish would otherwise look for a config in its own home and find nothing.

## Reading the prompt

| Element | Meaning |
| --- | --- |
| `~3` `+1` `?2` | modified, staged, untracked file counts |
| `↑2` `↓1` `↕2/1` | ahead, behind, diverged from upstream |
| `≡2` | stashes |
| `+4s` | last command's runtime, shown past 2s only |
| red `─▶` | last command exited non-zero |
| `NODE` / `NET` | only appear in directories with those projects |

## Fonts

Everything renders in stock DejaVu Sans Mono, which mintty ships with, so you don't
need a Nerd Font here. The `main` config does use Nerd Font glyphs throughout. If you
want the icon versions, take the symbols from `shell/.config/starship.toml` on `main`.
