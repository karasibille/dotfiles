#!/usr/bin/env bash
#
# Symlink the dotfiles into $HOME.
#
#   ./install.sh             create the links
#   ./install.sh --packages  first install the missing packages (packages.txt),
#                            with pacman/yay on Arch or apt on Ubuntu, the
#                            backlight udev rule (udev/) and the clock resync
#                            after resume (systemd/)
#   ./install.sh --dry-run   only show what would be done (with or without
#                            --packages)
#
# Safe to run again: correct links are left alone, other links are replaced
# and real files are moved to <name>.bak.<timestamp>.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
DRY_RUN=0
PACKAGES=0
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        --packages) PACKAGES=1 ;;
        *) echo "usage: $0 [--packages] [--dry-run]" >&2; exit 2 ;;
    esac
done

# source in the repository | target | command required to install it (- = always)
LINKS=(
    "zshrc      | $HOME/.zshrc        | zsh"
    "zsh_plugins.txt | $HOME/.zsh_plugins.txt | zsh"
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
    "autorandr/settings.ini | $CONFIG/autorandr/settings.ini | autorandr"
    "autorandr/postswitch   | $CONFIG/autorandr/postswitch   | autorandr"
    "ranger     | $CONFIG/ranger      | ranger"
    "kitty      | $CONFIG/kitty       | kitty"
    "alacritty  | $CONFIG/alacritty   | alacritty"
    "picom/picom.conf     | $CONFIG/picom.conf           | picom"
    "gtk-3.0/settings.ini | $CONFIG/gtk-3.0/settings.ini | -"
    "gtk-3.0/gtk.css      | $CONFIG/gtk-3.0/gtk.css      | -"
    "bin/theme  | $HOME/.local/bin/theme | python3"
    "bin/lock   | $HOME/.local/bin/lock  | i3lock"
    "bin/autolock | $HOME/.local/bin/autolock | python3"
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

# Package manager helpers: installed / available in the repositories
# shellcheck source=/dev/null
case "$(. /etc/os-release && echo " ${ID:-} ${ID_LIKE:-} ")" in
    *" arch "*) DISTRO=arch ;;
    *" ubuntu "* | *" debian "*) DISTRO=ubuntu ;;
    *) DISTRO= ;;
esac

installed() {
    case "$DISTRO" in
        arch) pacman -Q "$1" >/dev/null 2>&1 ;;
        ubuntu) dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed" ;;
    esac
}

available() {
    case "$DISTRO" in
        arch) pacman -Si "$1" >/dev/null 2>&1 ;;
        ubuntu) apt-cache show "$1" >/dev/null 2>&1 ;;
    esac
}

install_packages() {
    if [ -z "$DISTRO" ]; then
        echo "packages: unsupported distribution, see packages.txt" >&2
        return 1
    fi
    [ "$DISTRO" = ubuntu ] && run sudo apt-get update

    local column=1 repo=() aur=() manual=() line arch ubuntu purpose pkg candidate
    [ "$DISTRO" = ubuntu ] && column=2
    while IFS= read -r line; do
        case "$line" in "#"* | "") continue ;; esac
        IFS='|' read -r arch ubuntu purpose <<< "$line"
        pkg=$(trim "$([ "$column" = 1 ] && echo "$arch" || echo "$ubuntu")")
        purpose=$(trim "$purpose")

        case "$pkg" in
            -) manual+=("$purpose") ;;
            aur:*)
                installed "${pkg#aur:}" || aur+=("${pkg#aur:}") ;;
            *)
                # "eza/exa": the first available alternative
                local found=
                for candidate in ${pkg//\// }; do
                    if installed "$candidate"; then found=installed; break; fi
                    if available "$candidate"; then found="$candidate"; break; fi
                done
                case "$found" in
                    installed) ;;
                    "") manual+=("$purpose ($pkg not in the repositories)") ;;
                    *) [[ " ${repo[*]} " == *" $found "* ]] || repo+=("$found") ;;
                esac ;;
        esac
    done < "$DOTFILES/packages.txt"

    if [ ${#repo[@]} -gt 0 ]; then
        echo "install  ${repo[*]}"
        case "$DISTRO" in
            arch) run sudo pacman -S --needed "${repo[@]}" ;;
            ubuntu) run sudo apt-get install "${repo[@]}" ;;
        esac
    fi
    if [ ${#aur[@]} -gt 0 ]; then
        local helper
        helper=$(command -v yay || command -v paru || true)
        if [ -n "$helper" ]; then
            echo "aur      ${aur[*]}"
            run "$helper" -S --needed "${aur[@]}"
        else
            manual+=("from the AUR: ${aur[*]}")
        fi
    fi
    [ ${#repo[@]} -gt 0 ] || [ ${#aur[@]} -gt 0 ] || echo "ok       all packages installed"
    local item
    for item in "${manual[@]}"; do
        echo "manual   $item"
    done
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
        local backup
        backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
        echo "backup   $dst -> $backup"
        run mv "$dst" "$backup"
    else
        echo "link     $dst"
    fi

    run mkdir -p "$(dirname "$dst")"
    run ln -s "$src" "$dst"
}

# System side, with --packages as it needs sudo. Let the video group change
# the brightness (polybar backlight module). The rule is copied, not linked:
# udev may run before /home is mounted.
setup_system() {
    local rule=/etc/udev/rules.d/90-backlight.rules user=${USER:-$(id -un)}
    if cmp -s "$DOTFILES/udev/90-backlight.rules" "$rule"; then
        echo "ok       $rule"
    else
        echo "install  $rule"
        run sudo install -m 644 "$DOTFILES/udev/90-backlight.rules" "$rule"
        run sudo udevadm trigger --subsystem-match=backlight --action=add
    fi

    if id -nG "$user" | grep -qw video; then
        echo "ok       $user in the video group"
    else
        echo "group    add $user to video (effective at the next login)"
        run sudo usermod -aG video "$user"
    fi

    # Resync the clock with NTP after a resume (see the unit). Copied too:
    # systemd reads /etc/systemd/system before /home is mounted.
    local unit=resync-clock-after-resume.service
    if cmp -s "$DOTFILES/systemd/$unit" "/etc/systemd/system/$unit"; then
        echo "ok       /etc/systemd/system/$unit"
    else
        echo "install  /etc/systemd/system/$unit"
        run sudo install -m 644 "$DOTFILES/systemd/$unit" "/etc/systemd/system/$unit"
        run sudo systemctl daemon-reload
    fi
    if systemctl is-enabled -q "$unit" 2>/dev/null; then
        echo "ok       $unit enabled"
    else
        echo "enable   $unit"
        run sudo systemctl enable "$unit"
    fi
}

if [ "$PACKAGES" = 1 ]; then
    install_packages
    setup_system
fi

for entry in "${LINKS[@]}"; do
    IFS='|' read -r src dst cmd <<< "$entry"
    src=$(trim "$src"); dst=$(trim "$dst"); cmd=$(trim "$cmd")

    if [ "$cmd" != "-" ] && ! command -v "$cmd" >/dev/null 2>&1; then
        echo "skip     $dst ($cmd not installed)"
        continue
    fi
    link "$src" "$dst"
done

# Color files are generated, not versioned: create them on first install
if [ ! -L "$DOTFILES/xrdb/current" ] && command -v python3 >/dev/null 2>&1; then
    echo "theme    nord (first install)"
    run "$DOTFILES/bin/theme" --no-reload nord
fi

[ "$DRY_RUN" = 1 ] && echo "Dry run: nothing was changed."
exit 0
