# Disable fish greeting  
set -g fish_greeting

# Initialize starship
starship init fish | source

# Run fastfetch on interactive shells
if status is-interactive
    fastfetch
end
