# Fish on Windows

## Where fish reads its config

Fish on Windows may not read `~/.config/fish/config.fish` where you expect. msys2 decides
what `$HOME` means from `db_home` in `/etc/nsswitch.conf`. The desktop is set to
`db_home: windows cygwin desc`, so `$HOME` is `C:\Users\<user>` and fish reads
`C:\Users\<user>\.config\fish\config.fish`, not `C:\msys64\home\<user>\...`. A default
msys2 install does the opposite. Cygwin's fish is separate again, with its own home under
`C:\cygwin64\home\<user>`.

If a config seems to be ignored, ask fish where it actually looks:

```fish
echo $__fish_config_dir
```

`install.sh` asks every fish it finds this question instead of hardcoding paths, so the
config lands correctly either way, including when msys2 and cygwin fish are both present.
It translates the answer through that fish's own `cygpath`, because the path fish reports
comes from its mount table rather than the one the installing shell sees.

To configure a fish that lives somewhere unusual:

```sh
~/dotfiles/install.sh --fish-path /d/tools/fish/bin/fish.exe
```

## STARSHIP_CONFIG

`config.fish` sets `STARSHIP_CONFIG` explicitly for a related reason. `starship.exe` is a
native Windows binary and doesn't resolve the POSIX `$HOME` that fish hands it, so cygwin's
fish would otherwise look for a config in its own home and find nothing. The path it sets is
starship's default on Linux, so one line covers both platforms.

## Line endings

Line endings are pinned to LF in `.gitattributes`. Fish parses a trailing CR as part of the
token, so a CRLF checkout of `config.fish` breaks the shell in ways that look like syntax
errors in unrelated places. `core.autocrlf` is usually true on Windows, which is exactly why
the rule has to be in the repo rather than left to local config.
