# Disable fish greeting  
set -g fish_greeting

# Initialize starship
starship init fish | source

# Run fastfetch on interactive shells
if status is-interactive
    fastfetch
end

# Aliases
# ls
alias ls='eza'		           # basic
alias ll='eza -l'		   # long format
alias la='eza -la'		   # long format + hidden files
alias lt='eza --tree'		   # tree
alias lta='eza --tree -a'          # tree with hidden files  
alias ltl='eza --tree -l'          # tree with long format
alias ltla='eza --tree -la'        # tree with long format and hidden files
alias lt2='eza --tree --level=2'   # tree limited to 2 levels deep
alias lt3='eza --tree --level=3'   # tree limited to 3 levels deep
