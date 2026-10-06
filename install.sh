#!/usr/bin/env bash
#
# Symlink the dotfiles into $HOME.
#
#   ./install.sh            create the links
#   ./install.sh --dry-run  only show what would be done
#
# Safe to run again: correct links are left alone, other links are replaced
# and real files are moved to <name>.bak.<timestamp>.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

# source in the repository | target | command required to install it (- = always)
LINKS=(
    "zshrc      | $HOME/.zshrc        | zsh"
    "profile    | $HOME/.profile      | -"
    "npmrc      | $HOME/.npmrc        | npm"
    "Xresources | $HOME/.Xresources   | xrdb"
    "aliases    | $CONFIG/aliases     | zsh"
    "xrdb       | $CONFIG/xrdb        | xrdb"
    "fontconfig | $CONFIG/fontconfig  | fc-cache"
    "i3         | $CONFIG/i3          | i3"
    "polybar    | $CONFIG/polybar     | polybar"
    "rofi       | $CONFIG/rofi        | rofi"
    "dunst      | $CONFIG/dunst       | dunst"
    "redshift   | $CONFIG/redshift    | redshift"
    "ranger     | $CONFIG/ranger      | ranger"
    "kitty      | $CONFIG/kitty       | kitty"
    "alacritty  | $CONFIG/alacritty   | alacritty"
)

run() {
    if [ "$DRY_RUN" = 1 ]; then
        echo "    would run: $*"
    else
        "$@"
    fi
}

trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    echo "${s%"${s##*[![:space:]]}"}"
}

link() {
    local src="$DOTFILES/$1" dst="$2"

    if [ "$(readlink "$dst" 2>/dev/null)" = "$src" ]; then
        echo "ok       $dst"
        return
    fi

    if [ -L "$dst" ]; then
        echo "relink   $dst (was -> $(readlink "$dst"))"
        run rm "$dst"
    elif [ -e "$dst" ]; then
        local backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
        echo "backup   $dst -> $backup"
        run mv "$dst" "$backup"
    else
        echo "link     $dst"
    fi

    run mkdir -p "$(dirname "$dst")"
    run ln -s "$src" "$dst"
}

for entry in "${LINKS[@]}"; do
    IFS='|' read -r src dst cmd <<< "$entry"
    src=$(trim "$src"); dst=$(trim "$dst"); cmd=$(trim "$cmd")

    if [ "$cmd" != "-" ] && ! command -v "$cmd" >/dev/null 2>&1; then
        echo "skip     $dst ($cmd not installed)"
        continue
    fi
    link "$src" "$dst"
done

[ "$DRY_RUN" = 1 ] && echo "Dry run: nothing was changed."
exit 0
