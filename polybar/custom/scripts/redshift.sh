#!/bin/sh
#
# Redshift state for polybar (custom/redshift): its icon colored by the
# temperature it applies, or dimmed when it is off. A click toggles it (the
# module sends USR1 to this script), e.g. off for color-accurate photo
# editing. Refreshed every minute, and right away after a toggle.

# Color of the active theme (bin/theme), read from xrdb
color() {
    xrdb -query | awk -v key="$1" '$1 == "*" key ":" || $1 == "*." key ":" { print $2; exit }'
}

show() {
    if ! pgrep -x redshift >/dev/null; then
        echo "%{F$(color color8)}"
        return
    fi
    temp=$(redshift -p 2> /dev/null | grep temp | cut -d ":" -f 2 | tr -dc "[:digit:]")

    if [ -z "$temp" ]; then
        echo "%{F$(color color8)}"
    elif [ "$temp" -ge 5000 ]; then
        echo "%{F$(color color4)}"
    elif [ "$temp" -ge 4000 ]; then
        echo "%{F$(color color3)}"
    else
        echo "%{F$(color color1)}"
    fi
}

toggle() {
    kill "$sleeper" 2>/dev/null
    if pgrep -x redshift >/dev/null; then
        # Every instance, then neutral colors: each instance restores the
        # colors it found when it started, which are not neutral when it was
        # started over another one
        pkill -x redshift
        while pgrep -x redshift >/dev/null; do sleep 0.1; done
        redshift -x >/dev/null 2>&1
    else
        # Through i3, so that redshift belongs to the session, not to polybar
        i3-msg -q 'exec --no-startup-id redshift'
        sleep 0.5
    fi
}

trap toggle USR1
while true; do
    show
    sleep 60 &
    sleeper=$!
    wait "$sleeper"
done
