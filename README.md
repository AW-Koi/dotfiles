# My Dotfiles

Personal configuration files for my Arch Linux setup with Hyprland, managed with GNU Stow.

## 🖥️ Setup
- **OS**: Arch Linux
- **WM**: Hyprland
- **Terminal**: Kitty
- **Shell**: Fish
- **Bar**: Waybar
- **Launcher**: Wofi
- **Notifications**: Dunst
- **Prompt**: Starship

## 📁 Structure
```
dotfiles/
├── fish/           # Fish shell config & aliases
├── hypr/           # Hyprland window manager
├── kitty/          # Terminal emulator
├── shell/          # Bash config & Starship prompt
├── waybar/         # Status bar with custom themes
├── wofi/           # Application launcher
└── dunst/          # Notification daemon
```

## 🚀 Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Install GNU Stow:**
   ```bash
   sudo pacman -S stow
   ```

3. **Stow the configurations you want:**
   ```bash
   # Install all configs
   stow fish hypr kitty shell waybar wofi dunst
   
   # Or install individually
   stow fish      # Fish shell config
   stow hypr      # Hyprland config
   stow kitty     # Terminal config
   stow waybar    # Status bar
   ```

## 🎨 Features

### Waybar
- Custom themes and scripts
- System monitoring widgets

### Fish Shell
- Starship prompt integration
- Useful aliases (eza, etc.)
- Clean, minimal config

### Hyprland
- Optimized for daily workflow
- Clean window management

## 🔧 Usage

**Adding new configs:**
```bash
# Create proper stow structure
mkdir -p newapp/.config/newapp
# Add your config files
stow newapp
```

**Removing configs:**
```bash
stow -D packagename
```

**Updating:**
```bash
cd ~/dotfiles
git pull
stow -R packagename  # restow to apply changes
```

## 📝 Notes
- All symlinks point to files in this repository
- Edit files in `~/dotfiles/` - changes sync automatically
- Fish variables and other machine-specific files are gitignored

---
*Feel free to fork and adapt for your own setup!*
