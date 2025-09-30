# Themes.
ZSH_THEME="af-magic"

# Case-sensitive completion.
CASE_SENSITIVE="true"

# Disable bi-weekly auto-update checks.
zstyle ':omz:update' mode disabled

# Disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Disable URL backslash escaping
DISABLE_MAGIC_FUNCTIONS="true"

# Disable marking untracked files under VCS as dirty.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# History.
HIST_STAMPS="yyyy-mm-dd"

# Plugins.
plugins=(
	z
	archive
	extract
	git
	autojump
	zsh-autosuggestions
	zsh-syntax-highlighting
	)

# exports
[ -f ~/.config/common/.exports ] && source ~/.config/common/.exports

# Oh My Zsh.
source $ZSH/oh-my-zsh.sh

# setopt.zsh aliases functions
[ -f ~/.config/zsh/setopt.zsh ] && source ~/.config/zsh/setopt.zsh
[ -f ~/.config/common/.aliases ] && source ~/.config/common/.aliases
[ -f ~/.config/common/.functions ] && source ~/.config/common/.functions

# zshrc.local
[ -f ~/.config/zsh/.zshrc.local ] && source ~/.config/zsh/.zshrc.local

# dircolors.
[ -x "$(command -v dircolors)" ] && eval "$(dircolors -b ~/.config/dircolors/.dircolors >/dev/null)"

# Integrated fzf
if [ -x "$(command -v fzf)" ]; then
    [ ! -d "$HOME/.config/fzf/shell" ] && mkdir -p "$HOME/.config/fzf/shell" >/dev/null
    [ ! -f "$HOME/.config/fzf/shell/key-bindings.zsh" ] && cp /usr/share/doc/fzf/examples/key-bindings.zsh "$HOME/.config/fzf/shell/" >/dev/null
    [ -f "$HOME/.config/fzf/shell/key-bindings.zsh" ] && source "$HOME/.config/fzf/shell/key-bindings.zsh"
fi

# Base16 Shell.
[ -f ~/.local/bin/base16-oxide ] && source ~/.local/bin/base16-oxide
