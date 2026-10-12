#!/bin/sh
#
# Brightness step for the polybar backlight module: `backlight.sh up|down`
# moves it by 5 %, never below 5 % (0 turns some panels fully black).

dir=/sys/class/backlight/${BACKLIGHT:-intel_backlight}
max=$(cat "$dir/max_brightness")
cur=$(cat "$dir/brightness")
step=$((max * 5 / 100))

case "$1" in
    up) new=$((cur + step)) ;;
    down) new=$((cur - step)) ;;
    *) exit 1 ;;
esac

[ "$new" -gt "$max" ] && new=$max
[ "$new" -lt "$step" ] && new=$step
echo "$new" > "$dir/brightness"
