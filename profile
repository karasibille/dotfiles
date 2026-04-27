# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes npm global's bin if it exis
npm_prefix=$(npm get prefix)
if [ -d "$npm_prefix/bin" ] ; then
	PATH="$npm_prefix/bin:$PATH"
fi

if [ -d "$HOME/go/bin" ] ; then
    PATH="$HOME/go/bin:$PATH"
fi

if [ -d "$HOME/.cargo/bin" ] ; then
    PATH="$HOME/.cargo/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# set PATH so it includes clechomposer global's bin if it exis
#composer_prefix="$HOME/.config/composer/vendor"
#if [ -d "$composer_prefix/bin" ] ; then
#	PATH="$composer_prefix/bin:$PATH"
#fi

export EDITOR=nvim
export VISUAL=nvim
export MONITOR=eDP1

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
# xrandr --output $MONITOR --primary

. "$HOME/.cargo/env"
