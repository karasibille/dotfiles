# Powerlevel10k instant prompt, when it is the prompt (see zsh_plugins.txt).
# Should stay close to the top: anything asking for input goes above.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Environment (PATH, EDITOR…) shared with other shells
[ -f ~/.profile ] && source ~/.profile
typeset -U path

# antidote: ~/.antidote (git clone) or the zsh-antidote package (Arch AUR, Ubuntu)
for f in ~/.antidote/antidote.zsh /usr/share/zsh-antidote/antidote.zsh; do
    [ -f "$f" ] && { source "$f"; break; }
done

# Prompt choice for zsh_plugins.txt
has-p10k() { [[ -f ~/.p10k.zsh ]] }
no-p10k() { ! has-p10k }

# Plugins listed in ~/.zsh_plugins.txt (zsh_plugins.txt in the dotfiles)
(( $+functions[antidote] )) && antidote load
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

(( $+commands[thefuck] )) && eval "$(thefuck --alias)"
(( $+commands[rbenv] )) && eval "$(rbenv init - zsh)"

# Aliases, then untracked ones (secrets/)
for f in ~/.config/aliases/*(N.) ~/.config/aliases/secrets/*(N.); do
    source "$f"
done

# Machine-specific settings, not versioned
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
