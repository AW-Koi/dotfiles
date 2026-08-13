# My Dotfiles

Fish, starship, and git config for Arch and for Windows under msys2, in one branch.
`install.sh` works out which OS it is on and installs the right pieces.

The prompt is a green-phosphor terminal theme: three shades of green for normal state,
amber for anything that needs attention, red when a command fails. The Claude Code theme
in [claude-config](https://github.com/AW-Koi/claude-config) matches it.

```
┌─ahwoouser@AHWOO-01 …/AhwooClient «task/brand-pages»  MOD:3  STG:1  NEW:2     11:42:44
└─▶
```

## Install

```sh
git clone https://github.com/AW-Koi/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

Same two lines on Arch and in Git Bash on Windows. Pass `--dry-run` first to see what it
would touch without writing anything. Any file it replaces is copied to `*.backup`
alongside the original, and re-running it only touches what actually differs.

On Arch and macOS it symlinks, so editing a file in the repo takes effect immediately. On
Windows it copies, because symlinks need admin rights or Developer Mode and Git Bash
quietly produces a copy rather than failing. The script probes for this rather than
assuming, and prints which mode it chose.

## Structure

```
dotfiles/
├── install.sh                              # installs for the current OS
├── git/shared.gitconfig                    # git settings, included not copied
├── shared/                                 # both OSes
│   ├── .bashrc
│   └── .config/
│       ├── starship.toml                   # prompt theme
│       └── fish/
│           ├── config.fish                 # greeting off, starship init, aliases
│           └── functions/fish_title.fish   # terminal tab text
├── linux/                                  # Arch only
│   ├── .Xresources
│   └── .config/{hypr,waybar,kitty}/
└── windows/terminal/                       # tab icon + its generator
```

Each of `shared/` and `linux/` mirrors `$HOME`, so `stow shared linux` still works on Arch
if you prefer it to `install.sh`.

To add a config, drop it under `shared/`, `linux/`, or `windows/` mirroring where it lives
in `$HOME`, then re-run `install.sh`. Machine-local state stays out of git: `fish_variables`
and `*.backup` are ignored, and `install.sh` never copies a `.gitignore` into a live config
dir.

## Git config

`install.sh` adds one `include.path` line to `~/.gitconfig` pointing at
`git/shared.gitconfig`, rather than installing a file over the top of it. Shared settings
(identity, `init.defaultBranch = main`, `push.autoSetupRemote`) come from the repo, and
anything machine-local (`safe.directory` entries, credential helpers) stays in
`~/.gitconfig` where it belongs. Git expands `~` in `include.path` on every platform, so
the same line works in both places.

## Docs

- [Reading the prompt](docs/prompt.md): what each label and colour means, and the font
  constraint that decides which glyphs it can use.
- [Fish on Windows](docs/fish-on-windows.md): why fish may ignore `~/.config/fish`, and
  the `STARSHIP_CONFIG` and line-ending traps that come with it.
- [Windows Terminal](docs/windows-terminal.md): tab title and tab icon.
