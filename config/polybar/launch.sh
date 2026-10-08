#!/usr/bin/env sh

# One launch at a time: i3 and autorandr's postswitch hook may both run this
# at startup, which would start the bars twice. The bars don't inherit the
# lock (9>&-), so it is released when this script exits.
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/polybar-launch.lock"
flock 9

# Terminate already running bar instances
killall -q polybar

uid=$(id -u)
# Wait until the processes have been shut down
while pgrep -u "$uid" -x polybar >/dev/null; do sleep 1; done

# Hardware of this machine, for the battery and backlight modules: names
# differ between laptops (BAT0/BAT1, AC/ADP1, intel_backlight/amdgpu_bl0…)
for supply in /sys/class/power_supply/*; do
    case "$(cat "$supply/type" 2>/dev/null)" in
        Battery) BATTERY=${BATTERY:-${supply##*/}} ;;
        Mains) ADAPTER=${ADAPTER:-${supply##*/}} ;;
    esac
done
for card in /sys/class/backlight/*; do
    [ -e "$card" ] && BACKLIGHT=${card##*/} && break
done
export BATTERY ADAPTER BACKLIGHT

# The full bar on the primary monitor (the first one if none is primary), the
# secondary bar on the others. Lines look like "eDP1: 1920x1080+0+0 (primary)".
monitors=$(polybar --list-monitors)
primary=$(echo "$monitors" | grep '(primary)' | cut -d: -f1)
[ -n "$primary" ] || primary=$(echo "$monitors" | head -n 1 | cut -d: -f1)

# The backlight module is only useful while the laptop panel is on
main=top-nobacklight
echo "$monitors" | grep -qE '^(eDP|LVDS|DSI)' && main=top

for m in $(echo "$monitors" | cut -d: -f1); do
    if [ "$m" = "$primary" ]; then
        MONITOR=$m polybar "$main" 9>&- &
    else
        MONITOR=$m polybar secondary 9>&- &
    fi
done

echo "Bars launched..."
