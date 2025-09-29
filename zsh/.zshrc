# Load our dotfiles.
for file in ~/.config/common/.{aliases,exports,functions}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

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
	extract
	git 
	autojump 
	zsh-autosuggestions 
	zsh-syntax-highlighting
	)

# 
if [ -f ~/.config/zsh/setopt.zsh ]; then source ~/.config/zsh/setopt.zsh; fi
if [ -f ~/.config/zsh/.zshrc.local ]; then source ~/.config/zsh/.zshrc.local; fi

# Oh My Zsh.
source $ZSH/oh-my-zsh.sh
