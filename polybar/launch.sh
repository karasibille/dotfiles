#!/usr/bin/env sh

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

# Launch one bar per connected monitor
for m in $(polybar --list-monitors | cut -d: -f1); do
    MONITOR=$m polybar top &
done

echo "Bars launched..."
