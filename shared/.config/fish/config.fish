# Disable fish greeting
set -g fish_greeting

if status is-interactive
    # starship.exe on Windows is a native binary and does not read the shell's
    # POSIX $HOME, so the config path is set explicitly. On Linux this is already
    # starship's default, so the one line is correct on both.
    set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
    starship init fish | source

    if command -q fastfetch
        fastfetch
    end
end

if command -q eza
    alias ls='eza'
    alias ll='eza -l'
    alias la='eza -la'
    alias lt='eza --tree'
    alias lta='eza --tree -a'
    alias ltl='eza --tree -l'
    alias ltla='eza --tree -la'
    alias lt2='eza --tree --level=2'
    alias lt3='eza --tree --level=3'
end
