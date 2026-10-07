#!/usr/bin/env bash
#
# Install the GTK theme and cursor theme used by the dotfiles that aren't
# packaged on Ubuntu: Nordic into ~/.local/share/themes, the capitaine cursors
# into ~/.icons. On Arch, packages.txt installs them.
#
#   ./install-themes.sh            install the missing themes
#   ./install-themes.sh --dry-run  only show what would be done
#
# Safe to run again: a theme already installed (in ~/.local/share, ~/.themes,
# ~/.icons or /usr/share) is skipped.
set -euo pipefail

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
# libXcursor (X11 cursors) only looks in ~/.icons, not ~/.local/share/icons
declare -A DEST=([themes]="$DATA_DIR/themes" [icons]="$HOME/.icons")
DRY_RUN=0
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        *) echo "usage: $0 [--dry-run]" >&2; exit 2 ;;
    esac
done

# theme directory | kind (themes or icons) | archive URL | sha256 | directory in the archive holding the themes
THEMES=(
    "Nordic | themes | https://github.com/EliverLara/Nordic/releases/download/v2.2.0/Nordic.tar.xz | d162d694e13bec518636b193fbe84ccea44da9a81a89015c6713f6b258ee36d5 | ."
    # Not released prebuilt upstream: Arch's package holds capitaine-cursors and capitaine-cursors-light
    "capitaine-cursors-light | icons | https://archive.archlinux.org/packages/c/capitaine-cursors/capitaine-cursors-4-3-any.pkg.tar.zst | 86cccc178c7f492f72e23fdb8451f72f89c144377dbd3fe4d63a145b60cf0cde | usr/share/icons"
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

installed_in() {
    local name="$1" kind="$2" dir
    for dir in "$DATA_DIR/$kind" "$HOME/.$kind" "/usr/local/share/$kind" "/usr/share/$kind"; do
        [ -d "$dir/$name" ] && { echo "$dir/$name"; return 0; }
    done
    return 1
}

for cmd in curl tar sha256sum; do
    command -v "$cmd" >/dev/null 2>&1 || { echo "themes: $cmd is required" >&2; exit 1; }
done

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

for entry in "${THEMES[@]}"; do
    IFS='|' read -r name kind url sha inner <<< "$entry"
    name=$(trim "$name"); kind=$(trim "$kind"); url=$(trim "$url")
    sha=$(trim "$sha"); inner=$(trim "$inner")

    if found=$(installed_in "$name" "$kind"); then
        echo "ok       $name ($found)"
        continue
    fi

    dest=${DEST[$kind]}
    echo "install  $name -> $dest"
    archive="$tmp/${url##*/}"
    run curl -fsSL -o "$archive" "$url"
    if [ "$DRY_RUN" = 0 ] && ! echo "$sha  $archive" | sha256sum -c --quiet -; then
        echo "themes: checksum mismatch for $url" >&2
        exit 1
    fi
    # tar detects the compression (xz, zstd) itself
    run mkdir -p "$tmp/extract" "$dest"
    run tar -xf "$archive" -C "$tmp/extract"
    run cp -a "$tmp/extract/$inner/." "$dest/"
    run rm -rf "$tmp/extract"
done

[ "$DRY_RUN" = 1 ] && echo "Dry run: nothing was changed."
exit 0
