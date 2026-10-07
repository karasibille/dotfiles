#!/usr/bin/env bash
#
# Install the fonts used by the dotfiles that may be missing (Source Code Pro
# and Font Awesome 7 aren't packaged on Ubuntu) into ~/.local/share/fonts.
# On Arch, packages.txt installs them all.
#
#   ./install-fonts.sh            install the missing fonts
#   ./install-fonts.sh --dry-run  only show what would be done
#
# Safe to run again: a font already known to fontconfig is skipped, as is
# one whose alternative ("A/B") is.
set -euo pipefail

FONTS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
DRY_RUN=0
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        *) echo "usage: $0 [--dry-run]" >&2; exit 2 ;;
    esac
done

# family checked with fc-list ("A/B": either one) | directory | archive URL | sha256 | files in the archive
FONTS=(
    "Source Code Pro | source-code-pro | https://github.com/adobe-fonts/source-code-pro/releases/download/2.042R-u/1.062R-i/1.026R-vf/OTF-source-code-pro-2.042R-u_1.062R-i.zip | 754a2e3ebb945ae905d720ac5896b3b34acc9546dd6551ef9536869788629dae | OTF/*.otf"
    "Font Awesome 7 Free | font-awesome-7 | https://github.com/FortAwesome/Font-Awesome/releases/download/7.3.1/fontawesome-free-7.3.1-desktop.zip | c61edde261707f33376a28e9a30bb8c70c1a20bf0bd975206b809f3b3b70add5 | */otfs/*.otf"
    # polybar workspace names; Noto Sans CJK JP (fonts-noto-cjk) is the same typeface
    "Source Han Sans JP/Noto Sans CJK JP | source-han-sans-jp | https://github.com/adobe-fonts/source-han-sans/releases/download/2.005R/17_SourceHanSansJP.zip | 076a167394a2bf125a7ab13164a5ea1ce529b988d867c11052e83473b2a704f1 | SubsetOTF/JP/*.otf"
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

for cmd in curl unzip fc-list fc-cache sha256sum; do
    command -v "$cmd" >/dev/null 2>&1 || { echo "fonts: $cmd is required" >&2; exit 1; }
done

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

installed=0
for entry in "${FONTS[@]}"; do
    IFS='|' read -r family dir url sha files <<< "$entry"
    family=$(trim "$family"); dir=$(trim "$dir"); url=$(trim "$url")
    sha=$(trim "$sha"); files=$(trim "$files")

    # fc-list prints "Family" or "Family,Other name"
    known=$'\n'"$(fc-list : family)"$'\n' found=
    IFS=/ read -ra names <<< "$family"
    for name in "${names[@]}"; do
        if [[ $known == *$'\n'"$name"[$'\n',]* ]]; then found=$name; break; fi
    done
    if [ -n "$found" ]; then
        echo "ok       $found"
        continue
    fi

    echo "install  ${names[0]} -> $FONTS_DIR/$dir"
    archive="$tmp/$dir.zip"
    run curl -fsSL -o "$archive" "$url"
    if [ "$DRY_RUN" = 0 ] && ! echo "$sha  $archive" | sha256sum -c --quiet -; then
        echo "fonts: checksum mismatch for $url" >&2
        exit 1
    fi
    run mkdir -p "$FONTS_DIR/$dir"
    run unzip -qjo "$archive" "$files" -d "$FONTS_DIR/$dir"
    installed=1
done

[ "$installed" = 1 ] && run fc-cache -f "$FONTS_DIR"
[ "$DRY_RUN" = 1 ] && echo "Dry run: nothing was changed."
exit 0
