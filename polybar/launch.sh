#!/usr/bin/env sh

# Terminate already running bar instances
killall -q polybar

uid=$(id -u)
# Wait until the processes have been shut down
while pgrep -u $uid -x polybar >/dev/null; do sleep 1; done

# Launch bar1 and bar2
MONITOR=eDP1 polybar top &
MONITOR=DP1 polybar top &
MONITOR=HDMI-1-0 polybar top &

echo "Bars launched..."
