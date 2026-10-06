#!/bin/sh

# Color of the active theme (bin/theme), read from xrdb
color() {
    xrdb -query | awk -v key="$1" '$1 == "*" key ":" || $1 == "*." key ":" { print $2; exit }'
}

if [ "$(pgrep -x redshift)" ]; then
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
fi
