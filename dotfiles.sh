#!/bin/bash

# Set color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Set stow-managed directory
DOTFILES_DIR="$HOME/.dotfiles"

# oh-my-zsh directories
ZSH="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH/custom"

# Check if a software package is installed
is_installed() {
    # Check apt-installed packages
    if dpkg -l | grep -q "$1"; then
        return 0  # Installed via apt
    fi

    # Check git-installed packages (stored in a specific directory)
    if [ -d "$1" ]; then
        return 0  # Directory exists and is a git repo → installed
    fi

    return 1  # Neither installed via apt nor git
}

# Install an apt package
install_apt_package() {
    if ! is_installed "$1"; then
        echo -e "${YELLOW}Installing missing package: $1${NC}"
        sudo apt update &>/dev/null
        sudo apt install -y "$1" &>/dev/null
    else
        echo -e "${GREEN}$1 is already installed${NC}"
    fi
}

# Clone and install via git
install_git_repo() {
    local repo="$1"
    local dir="$2"

    if ! is_installed "$dir"; then
        echo -e "${YELLOW}Cloning Git repo: $repo${NC}"
        git clone "$repo" "$dir" &>/dev/null
    else
        echo -e "${GREEN}$dir already exists, skipping clone${NC}"
    fi
}

# Install oh-my-zsh
install_oh_my_zsh() {
    # zsh
    install_apt_package "zsh"

    if [ ! -d "$ZSH" ]; then
        echo -e "${YELLOW}Installing Oh-My-Zsh ...${NC}"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended &>/dev/null
    else
        echo -e "${GREEN}Oh-My-Zsh is already installed${NC}"
    fi

    # autojump
    install_apt_package "autojump"
    # zsh-autosuggestions
    install_git_repo "https://github.com/zsh-users/zsh-autosuggestions.git" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    # zsh-syntax-highlighting
    install_git_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    # extract
    install_git_repo "https://github.com/xvoland/Extract.git" "$ZSH_CUSTOM/plugins/extract"
}

# Backup existing config files
backup_config() {
    local target="$1"

    if [ -f "$target" ] || [ -L "$target" ]; then
        local backup_target="${target/#$HOME/$HOME/.dotfiles_backup}"
        local backup_dir="$(dirname "$backup_target")"

        if [ ! -d "$backup_dir" ]; then
            mkdir -p "$backup_dir" &>/dev/null
        fi

        echo -e "${YELLOW}Backing up $target to $backup_target${NC}"
        mv "$target" "$backup_target" &>/dev/null
    fi
}

# Link files using stow
stow_link() {
    local package="$1"
    echo -e "${BLUE}Stowing package $package...${NC}"

    local package_dir="$DOTFILES_DIR/$package"

    # Backup if already installed or config files exist
    if [ -d "$package_dir" ]; then
        find "$package_dir" -type f | while IFS= read -r file; do
            local target="${file/#$package_dir/$HOME}"
            backup_config "$target"
        done

        stow --no-folding -d "$DOTFILES_DIR" -t "$HOME" "$package" &>/dev/null
    else
        echo -e "${RED}Stow package $package does not exist, skipping${NC}"
    fi
}

# Install dependencies or plugins (customize as needed)
install_dependencies_or_plugins() {
    echo -e "${BLUE}Installing packages...${NC}"

    # x11-xserver-utils
    install_apt_package "x11-xserver-utils"
    # coreutils
    install_apt_package "coreutils"
    # locales
    install_apt_package "locales"

    # font support
    install_apt_package "fonts-font-awesome"
    install_apt_package "fonts-hack-ttf"

    # git
    install_apt_package "git"
    # diff-so-fancy download + symlink
    install_git_repo "https://github.com/so-fancy/diff-so-fancy.git" "$HOME/.local/share/diff-so-fancy"
    ln -sf "$HOME/.local/share/diff-so-fancy/diff-so-fancy" "$HOME/.local/bin/diff-so-fancy"

    # stow
    install_apt_package "stow"

    # oh-my-zsh
    install_oh_my_zsh

    # net-tools
    install_apt_package "net-tools"
    # traceroute
    install_apt_package "traceroute"

    # neovim
    install_apt_package "neovim"
    # vim
    install_apt_package "vim"
    # glow
    install_apt_package "glow"
    # bat
    install_apt_package "bat"

    # ssh
    install_apt_package "openssh-server"
    install_apt_package "openssh-client"

    # wget
    install_apt_package "wget"
    # curl
    install_apt_package "curl"

    # tmux
    install_apt_package "tmux"
    # fzf
    install_apt_package "fzf"
    # ripgrep
    install_apt_package "ripgrep"
    # nnn
    install_apt_package "nnn"
    # lrzsz
    install_apt_package "lrzsz"
    # htop
    install_apt_package "htop"
    # xclip
    install_apt_package "xclip"
    # yt-dlp
    install_apt_package "yt-dlp"

    # alacritty
    install_apt_package "alacritty"
}

# Link modules (customize as needed)
link_module(){
    echo -e "${BLUE}Linking modules...${NC}"

    # bin
    stow_link "bin"

    # dircolors
    stow_link "dircolors"

    # bash
    stow_link "bash"

    # zsh
    stow_link "zsh"

    # common
    stow_link "common"

    # ssh
    stow_link "ssh"

    # git
    stow_link "git"

    # tmux
    stow_link "tmux"

    # bat
    stow_link "bat"

    # glow
    stow_link "glow"

    # htop
    stow_link "htop"

    # nvim
    stow_link "nvim"

    # vim
    stow_link "vim"

    # wget
    stow_link "wget"

    # yt-dlp
    stow_link "yt-dlp"

    # ripgrep
    stow_link "ripgrep"

    # alacritty
    stow_link "alacritty"
}

# Main entry point
main() {
    echo -e "${GREEN}dotfiles installation started...${NC}"

    # Install dependencies or plugins (customize as needed)
    install_dependencies_or_plugins

    # Link modules (customize as needed)
    link_module

    echo -e "${GREEN}dotfiles installation completed!${NC}"
}

main "$@"
