#!/usr/bin/env bash
# Installs the dotfiles for whichever OS this is. Symlinks where the filesystem
# supports it and copies where it does not, so the same script works on Arch and
# in Git Bash / msys2 on Windows.
set -euo pipefail

repo=$(cd "$(dirname "$0")" && pwd)
dry_run=0
update_terminal=0
mode=copy
installed=0
skipped=0

usage() {
    cat <<'EOF'
Usage: install.sh [--dry-run] [--update-terminal] [--fish-path PATH]...

  --dry-run          Report what would change without writing anything.
  --update-terminal  Windows only: point the Windows Terminal fish profile at
                     this repo's tab icon. Requires jq.
  --fish-path PATH   Extra fish binary to configure alongside the probed ones.
                     May be repeated.
EOF
}

extra_fish=()
while [ $# -gt 0 ]; do
    case $1 in
        --dry-run) dry_run=1 ;;
        --update-terminal) update_terminal=1 ;;
        --fish-path) shift; [ $# -gt 0 ] || { echo "--fish-path needs a value" >&2; exit 2; }; extra_fish+=("$1") ;;
        -h|--help) usage; exit 0 ;;
        *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done

case $(uname -s) in
    Linux)            os=linux ;;
    Darwin)           os=macos ;;
    MINGW*|MSYS*|CYGWIN*) os=windows ;;
    *)                echo "unsupported platform: $(uname -s)" >&2; exit 1 ;;
esac

say()  { printf '  %s\n' "$1"; }
head2() { printf '\n%s\n' "$1"; }

# Symlinks need admin rights or Developer Mode on Windows, and Git Bash silently
# creates a copy instead of failing, so link support is probed rather than assumed.
detect_mode() {
    local probe target
    probe=$(mktemp -d)
    target="$probe/target"
    : >"$target"
    if ln -s "$target" "$probe/link" 2>/dev/null && [ -L "$probe/link" ]; then
        mode=symlink
    else
        mode=copy
    fi
    rm -rf "$probe"
}

# The ~ in the display substitutions stays backslash-escaped: bare ~ is tilde
# expanded to $HOME, which turns the replacement into a no-op.
install_file() {
    local src=$1 dest=$2

    if [ "$mode" = symlink ] && [ "$(readlink "$dest" 2>/dev/null)" = "$src" ]; then
        skipped=$((skipped + 1))
        return
    fi
    if [ "$mode" = copy ] && [ -f "$dest" ] && cmp -s "$src" "$dest"; then
        skipped=$((skipped + 1))
        return
    fi

    if [ "$dry_run" = 1 ]; then
        say "would install  ${dest/#$HOME/\~}"
        installed=$((installed + 1))
        return
    fi

    mkdir -p "$(dirname "$dest")"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        cp -f "$dest" "$dest.backup"
        say "backed up      ${dest/#$HOME/\~}.backup"
    fi

    rm -f "$dest"
    if [ "$mode" = symlink ]; then
        ln -s "$src" "$dest"
    else
        cp -f "$src" "$dest"
    fi
    say "installed      ${dest/#$HOME/\~}"
    installed=$((installed + 1))
}

# .gitignore keeps fish_variables out of the repo; it is not part of the config
# and must never land in a live config dir.
install_tree() {
    local src_root=$1 dest_root=$2 exclude=${3:-}
    local src rel
    [ -d "$src_root" ] || return 0

    while IFS= read -r src; do
        rel=${src#"$src_root"/}
        [ "$(basename "$rel")" = .gitignore ] && continue
        [ -n "$exclude" ] && case $rel in $exclude) continue ;; esac
        install_file "$src" "$dest_root/$rel"
    done < <(find "$src_root" -type f | sort)
}

win_to_posix() {
    if command -v cygpath >/dev/null 2>&1; then
        cygpath -u "$1"
    else
        printf '%s' "$1" | sed 's|\\|/|g; s|^\([A-Za-z]\):|/\l\1|'
    fi
}

# fish resolves ~ from its own mount table, which differs between msys2 and
# cygwin and shifts with nsswitch.conf db_home. Ask each fish where it reads its
# config from rather than assuming a path.
fish_config_dirs() {
    local candidates=() exe reported translated sibling
    if [ "$os" = windows ]; then
        candidates+=(/c/msys64/usr/bin/fish.exe /c/cygwin64/bin/fish.exe)
    fi
    command -v fish >/dev/null 2>&1 && candidates+=("$(command -v fish)")
    [ ${#extra_fish[@]} -gt 0 ] && candidates+=("${extra_fish[@]}")
    [ ${#candidates[@]} -gt 0 ] || return 0

    for exe in "${candidates[@]}"; do
        [ -x "$exe" ] || continue
        reported=$("$exe" -c 'echo $__fish_config_dir' 2>/dev/null) || continue
        [ -n "$reported" ] || continue

        if [ "$os" = windows ]; then
            sibling=$(dirname "$exe")/cygpath.exe
            [ -x "$sibling" ] || continue
            translated=$("$sibling" -w "$reported" 2>/dev/null) || continue
            [ -n "$translated" ] || continue
            win_to_posix "$translated"
        else
            printf '%s\n' "$reported"
        fi
    done | sort -u
}

install_gitconfig_include() {
    local target=$repo/git/shared.gitconfig include existing

    # git expands ~ in include.path on every platform, which sidesteps the
    # /c/Users vs C:/Users split that a literal absolute path would hit here.
    case $repo/ in
        "$HOME"/*) include="~${repo#"$HOME"}/git/shared.gitconfig" ;;
        *) if [ "$os" = windows ] && command -v cygpath >/dev/null 2>&1; then
               include=$(cygpath -m "$target")
           else
               include=$target
           fi ;;
    esac

    while IFS= read -r existing; do
        if [ "$existing" = "$include" ]; then
            say "unchanged      ~/.gitconfig already includes it"
            skipped=$((skipped + 1))
            return
        fi
    done < <(git config --global --get-all include.path 2>/dev/null || true)

    if [ "$dry_run" = 1 ]; then
        say "would add      include.path = $include"
        installed=$((installed + 1))
        return
    fi
    git config --global --add include.path "$include"
    say "wired          include.path = $include"
    installed=$((installed + 1))
}

update_windows_terminal() {
    local settings icon config
    settings="$(win_to_posix "${LOCALAPPDATA:-}")/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
    icon=$repo/windows/terminal/fish.png

    if ! command -v jq >/dev/null 2>&1; then
        say "jq is not installed, skipping the tab icon."
        return
    fi
    if [ ! -f "$settings" ]; then
        say "Windows Terminal settings.json not found, skipping."
        return
    fi
    if [ ! -f "$icon" ]; then
        say "$icon is missing, run windows/terminal/generate-icon.ps1 first."
        return
    fi
    if command -v cygpath >/dev/null 2>&1; then
        icon=$(cygpath -w "$icon")
    fi

    if [ "$dry_run" = 1 ]; then
        say "would set      fish profile icon in Windows Terminal"
        return
    fi

    config=$(jq --arg icon "$icon" \
        '.profiles.list |= map(if (((.name // "") | test("fish")) or ((.commandline // "") | test("fish"))) then .icon = $icon else . end)' \
        "$settings")
    cp -f "$settings" "$settings.backup"
    printf '%s\n' "$config" >"$settings"
    say "updated        Windows Terminal fish profile icon"
}

detect_mode
printf '\ndotfiles -> %s (%s, %s)\n' "$HOME" "$os" "$mode"

head2 "shared"
install_tree "$repo/shared" "$HOME" '.config/fish/*'

head2 "fish"
fish_dirs=$(fish_config_dirs)
if [ -z "$fish_dirs" ]; then
    say "no fish installation found, skipping its config."
    [ "$os" = windows ] && say "install it with: pacman -S fish   (inside msys2)"
else
    while IFS= read -r dir; do
        say "${dir/#$HOME/\~}"
        install_tree "$repo/shared/.config/fish" "$dir"
    done <<<"$fish_dirs"
fi

if [ "$os" = linux ]; then
    head2 "linux"
    install_tree "$repo/linux" "$HOME"
fi

head2 "git"
install_gitconfig_include

if [ "$update_terminal" = 1 ]; then
    head2 "Windows Terminal"
    if [ "$os" = windows ]; then
        update_windows_terminal
    else
        say "--update-terminal only applies on Windows, skipping."
    fi
fi

printf '\n%s changed, %s already current.\n' "$installed" "$skipped"
if ! command -v starship >/dev/null 2>&1; then
    printf '\nstarship is not on PATH. Install it with:\n'
    case $os in
        linux) printf '  sudo pacman -S starship\n' ;;
        macos) printf '  brew install starship\n' ;;
        windows) printf '  winget install --id Starship.Starship\n' ;;
    esac
fi
printf '\nOpen a new shell to pick up the prompt.\n\n'
