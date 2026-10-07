#!/usr/bin/env sh

# Terminate already running bar instances
killall -q polybar

uid=$(id -u)
# Wait until the processes have been shut down
while pgrep -u "$uid" -x polybar >/dev/null; do sleep 1; done

# Launch one bar per connected monitor
for m in $(polybar --list-monitors | cut -d: -f1); do
    MONITOR=$m polybar top &
done

echo "Bars launched..."
