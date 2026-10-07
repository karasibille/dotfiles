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

# The yarn plugin runs `yarn global bin` (~500 ms) to add it to PATH: it is
# ~/.local/bin (the npm prefix, see ~/.npmrc), already in PATH
zstyle ':omz:plugins:yarn' global-path false

# Compile the plugins and the static plugin file: ~40 ms faster to load
zstyle ':antidote:bundle:*' zcompile 'yes'
zstyle ':antidote:static' zcompile 'yes'

# zsh-autosuggestions rebinds every widget before each prompt (~25 ms); all
# plugins are loaded by the first prompt, so binding once then is enough
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Plugins listed in ~/.zsh_plugins.txt (zsh_plugins.txt in the dotfiles)
(( $+functions[antidote] )) && antidote load
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Without ~/.p10k.zsh powerlevel10k isn't loaded: load it on demand so that
# `p10k configure` can create that file
if (( ! $+functions[p10k] && $+functions[antidote] )); then
    p10k() {
        unfunction p10k
        source "$(antidote path romkatv/powerlevel10k)/powerlevel10k.zsh-theme" && p10k "$@"
    }
fi

(( $+commands[thefuck] )) && eval "$(thefuck --alias)"
(( $+commands[rbenv] )) && eval "$(rbenv init - zsh)"

# Aliases, then untracked ones (secrets/)
for f in ~/.config/aliases/*(N.) ~/.config/aliases/secrets/*(N.); do
    source "$f"
done

# Machine-specific settings, not versioned
# (an if, so that the first prompt does not start with a failed status)
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi
