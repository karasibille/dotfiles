#!/bin/sh
#
# Microphone state for polybar (custom/mic): the default source, muted or not,
# printed again as soon as it changes (pactl subscribe). Nothing when the
# default source is a monitor, i.e. there is no microphone (e.g. an output-only
# card profile, which pavucontrol's Configuration tab changes).

show() {
    case "$(pactl get-default-source 2>/dev/null)" in
        "" | *.monitor) echo "" ;;
        *)
            if pactl get-source-mute @DEFAULT_SOURCE@ | grep -q yes; then
                echo ""
            else
                echo ""
            fi ;;
    esac
}

show
pactl subscribe 2>/dev/null | while read -r event; do
    case "$event" in
        *" on source "* | *" on server "*) show ;;
    esac
done
