source ~/.profile
source /usr/share/zsh/share/antigen.zsh

antigen use oh-my-zsh

antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions

antigen bundle git
antigen bundle npm
antigen bundle yarn
antigen bundle composer
antigen bundle httpie
antigen bundle common-aliases
antigen bundle autojump
antigen bundle jasonmccreary/git-trim@main
antigen bundle paulirish/git-open

antigen theme fwalch
antigen apply

eval $(thefuck --alias)

source ~/.config/aliases/utils
source ~/.config/aliases/git
source ~/.config/aliases/exa

source /usr/share/autojump/autojump.zsh
eval "$(rbenv init - zsh)"
