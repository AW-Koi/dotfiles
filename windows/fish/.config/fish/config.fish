# Disable fish greeting
set -g fish_greeting

if status is-interactive
    # starship.exe is a native Windows binary and does not read the shell's
    # POSIX $HOME, so point it at the config explicitly. Keep this Windows-style
    # path assignment out of the Linux config.
    set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
    starship init fish | source
end
