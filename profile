# Prepend a directory to PATH if it exists and isn't already there
prepend_path() {
    [ -d "$1" ] || return 0
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$1:$PATH" ;;
    esac
}

prepend_path "$HOME/bin"
prepend_path "$HOME/.cargo/bin"
prepend_path "$HOME/.symfony/bin"
prepend_path "$HOME/go/bin"
prepend_path "$HOME/.local/bin" # also the npm prefix, see ~/.npmrc
export PATH
unset -f prepend_path

export EDITOR=nvim
export VISUAL=nvim

# Preferred terminal, used by i3-sensible-terminal
for t in kitty alacritty; do
    command -v "$t" >/dev/null 2>&1 && { export TERMINAL="$t"; break; }
done
unset t

# systemd user ssh-agent (systemctl --user enable --now ssh-agent)
if [ -S "$XDG_RUNTIME_DIR/ssh-agent.socket" ]; then
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
fi

# Machine-specific settings, not versioned
[ -f "$HOME/.profile.local" ] && . "$HOME/.profile.local"
