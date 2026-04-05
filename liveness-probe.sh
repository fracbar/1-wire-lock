#!/bin/bash
# Liveness probe - checks if the 1-wire-lock script is running and monitoring

# Check if the main process is running
if ! pgrep -f "1-wire-lock.sh" > /dev/null; then
    echo "ERROR: 1-wire-lock.sh is not running"
    exit 1
fi

echo "OK: 1-wire-lock is running"
exit 0
