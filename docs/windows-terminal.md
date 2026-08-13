# Windows Terminal

## Tab title

The tab title comes from `fish_title`, which prints the current directory's name. Fish's
default prints `prompt_pwd`, which renders as `/c/A/D/AhwooClient` and is illegible at tab
width.

## Tab icon

The icon is `windows/terminal/fish.png`, drawn to match the prompt. To point the fish profile
at it:

```sh
~/dotfiles/install.sh --update-terminal
```

That rewrites `icon` on any profile whose name or command line mentions fish, backing up
`settings.json` first. It needs `jq`. It stores an absolute path, so keep the repo somewhere
permanent (`~/dotfiles`) rather than a temp directory.

`windows/terminal/generate-icon.ps1` redraws the PNG from GDI+ primitives if you want to
change the colours or the shape. It stays PowerShell because it draws with .NET and runs once
when the artwork changes, so it is not part of installing.
