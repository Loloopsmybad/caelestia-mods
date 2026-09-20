#!/bin/bash

# Start daemon if not running
if ! awww query &>/dev/null; then
    awww-daemon &
    sleep 0.3
fi

awww img "$1" -t grow --transition-duration 0.5
