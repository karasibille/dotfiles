# Environment (PATH, EDITOR…) shared with other shells
[ -f ~/.profile ] && source ~/.profile
typeset -U path

# antigen: Arch (AUR antigen) or Ubuntu (zsh-antigen) location
for f in /usr/share/zsh/share/antigen.zsh /usr/share/zsh-antigen/antigen.zsh ~/.antigen.zsh; do
    [ -f "$f" ] && { source "$f"; break; }
done

if (( $+functions[antigen] )); then
    antigen use oh-my-zsh

    antigen bundle zsh-users/zsh-syntax-highlighting
    antigen bundle zsh-users/zsh-autosuggestions

    antigen bundle git
    antigen bundle npm
    antigen bundle yarn
    antigen bundle composer
    antigen bundle httpie
    antigen bundle common-aliases
    antigen bundle z
    antigen bundle colored-man-pages
    antigen bundle jasonmccreary/git-trim@main
    antigen bundle paulirish/git-open

    antigen theme fwalch
    antigen apply
fi

(( $+commands[thefuck] )) && eval "$(thefuck --alias)"
(( $+commands[rbenv] )) && eval "$(rbenv init - zsh)"

# Aliases, then untracked ones (secrets/)
for f in ~/.config/aliases/*(N.) ~/.config/aliases/secrets/*(N.); do
    source "$f"
done

# Machine-specific settings, not versioned
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
