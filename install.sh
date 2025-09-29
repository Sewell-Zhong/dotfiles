#!/usr/bin/env bash
set -e

# ==============================================================
# dotfiles installation script
# ==============================================================
# Purpose:
#   Centrally installs system dependencies, plugins, and themes, and manages symbolic links using GNU stow.
#   Supports the XDG directory specification and automatically backs up conflicting files before linking.
#
# Key Variable Descriptions:
#
# 1. DEPENDENCIES
#   Format: [name]="Required|Download URL|Installation Method|Target Path"
#   - Required: true/false, whether to force installation
#   - Download URL: Source/Binary/Git repository address, can be empty for brew
#   - Installation Method: source | binary | brew | git
#   - Target Path: Final installation location (e.g., /usr/local/bin/nvim)
#
# 2. MODULES
#   - Configuration modules to be managed using stow
#
# 3. DOTFILES_DIR
#   - Dotfiles repository path, defaults to $HOME/.dotfiles
#
# Usage:
#   chmod +x install.sh
#   ./install.sh
#
# ==============================================================

# -------------------------
# Color Definition
# -------------------------
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

echo -e "${GREEN}Starting installation of dotfiles...${RESET}"

# --------------------------------------------------
# Configuration area: dependencies and modules
# --------------------------------------------------
# Format: [name]="Required|Download URL|Installation Method|Target Path"
declare -A DEPENDENCIES=(
    [git]="false||apt|"
    [zsh]="false||apt|"
    [tmux]="false||apt|"
    [curl]="false||apt|"
    [stow]="false||apt|"
    [neovim]="false||apt|"
    [htop]="false||apt|"
    [vim]="false||apt|"
    [locales]="false||apt|"
    [alacritty]="false||apt|"
)

declare -A MODULES=(
    [bash]=true
    [common]=true
    [git]=true
    [htop]=true
    [nvim]=true
    [ssh]=true
    [tmux]=true
    [vim]=true
    [zsh]=true
    [alacritty]=true
)

DOTFILES_DIR="$HOME/.dotfiles"

# -------------------------
# Dependency installation function
# -------------------------
install_package_or_plugin() {
    local name=$1
    local value=$2
    IFS='|' read -r required url install_method target_path <<< "$value"

    if [ "$required" == "false" ]; then
        echo -e "${YELLOW}$name not required, skip installation${RESET}"
        return
    fi

    echo -e "${YELLOW}Installing $name ...${RESET}"

    case "$install_method" in
        "apt")
            if command -v apt &> /dev/null; then
                sudo apt update &> /dev/null && sudo apt install -y "$name"
            else
                echo -e "${RED}apt is not installed, cannot install $name${RESET}"
            fi
            ;;
        "brew")
            if command -v brew &> /dev/null; then
                brew install "$name"
            else
                echo -e "${RED}Homebrew is not installed, cannot install $name${RESET}"
            fi
            ;;
        "git")
            if [ ! -e "$target_path" ] ; then
                git clone "$url" "$target_path"
            else
                echo -e "${RED}Detect that $target_path already exists, cannot download $name${RESET}"
            fi

            ;;
        *)
            echo -e "${RED}Unknown installation method: $install_method${RESET}"
            ;;
    esac

    # echo -e "${GREEN}$name installation completed${RESET}"
}

# -------------------------
# Backup and Recovery
# -------------------------
backup_and_remove() {
    local target=$1
    local backup_path=$2

    if [ -e "$target" ] || [ -L "$target" ]; then
        echo -e "${YELLOW}Detect that $target exists, move to the $backup_path directory${RESET}"

        mv  "$target" "$backup_path/"
    fi
}

# -------------------------
# 1. Install dependencies
# -------------------------
for dep_name in "${!DEPENDENCIES[@]}"; do
    install_package_or_plugin "$dep_name" "${DEPENDENCIES[$dep_name]}"
done

# ------------------------
# 2. Install Oh-My-Zsh
# ------------------------
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$ZSH/custom"

if [ ! -d "$ZSH" ]; then
    echo -e "${YELLOW}Installing Oh-My-Zsh ...${RESET}"
    sh -c "$(curl -fsSL https://github.sewellzhong.com/https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# -------------------------
# 3. Install zsh plugins
# -------------------------
# Format: [name]="Required|Download URL|Installation Method|Target Path"
declare -A ZSH_CUSTOM_PACKAGE=(
    [zsh-autosuggestions]="false|https://github.sewellzhong.com/https://github.com/zsh-users/zsh-autosuggestions|git|$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    [zsh-syntax-highlighting]="false|https://github.sewellzhong.com/https://github.com/zsh-users/zsh-syntax-highlighting|git|$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    [extract]="false|https://github.sewellzhong.com/https://github.com/xvoland/Extract.git|git|${ZSH_CUSTOM}/plugins/extract"
)

for zsh_package_name in "${!ZSH_CUSTOM_PACKAGE[@]}"; do
    install_package_or_plugin "$zsh_package_name" "${ZSH_CUSTOM_PACKAGE[$zsh_package_name]}"
done

# -------------------------
# 4. stow link module (automatic backup)
# -------------------------
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
for module in "${!MODULES[@]}"; do
    if [ "${MODULES[$module]}"  = false ]; then
        echo -e "${YELLOW}$module not required, skip link${RESET}"
        continue
    fi

    module_dir="$DOTFILES_DIR/$module"

    declare -a backup_target
    mapfile -d '' backup_target < <(find "$module_dir" -mindepth 1 -maxdepth 1  -print0 2>/dev/null)

    for target in "${backup_target[@]}"; do
        file_name=$(basename "$target")

        if [ -d "$target" ] && [ "$file_name" = ".config" ]; then
            target_file="$HOME/.config/$module"

            if [ ! -e "$target_file" ] ; then
                mkdir -p "$target_file"
            fi
        elif [ -d "$target" ] ; then
            target_file="$HOME/$file_name"

            if [ ! -e "$target_file" ] ; then
                mkdir -p "$target_file"
            fi
        else
            target_file="$HOME/$file_name"
        fi

        backup_and_remove "$target_file" "$BACKUP_DIR"
    done

    # stow link
    echo -e "${YELLOW}Linking module $module ...${RESET}"

    stow -d "$DOTFILES_DIR" --target="$HOME" "$module"

done

echo -e "${GREEN}Dotfiles installation complete! Please reopen the terminal${RESET}"
