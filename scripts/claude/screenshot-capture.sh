#!/usr/bin/env bash
#
# Interactive screenshot capture for Claude Code analysis
# Falls back to most recent screenshot if capture is cancelled

set -euo pipefail

# Set up directories
SCREENSHOT_DIR="./screenshots"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
SCREENSHOT_PATH="${SCREENSHOT_DIR}/screenshot_${TIMESTAMP}.png"

# Ensure screenshots directory exists
mkdir -p "$SCREENSHOT_DIR"

# Capture interactive screenshot
# -i: interactive mode (user selects area)
# -x: no sound
echo "Select an area to capture (press ESC to use most recent screenshot)..."
if screencapture -i -x "$SCREENSHOT_PATH" 2>/dev/null; then
    # Check if file was actually created (user might have cancelled)
    if [ -f "$SCREENSHOT_PATH" ]; then
        echo "$SCREENSHOT_PATH"
        exit 0
    fi
fi

# Fallback: Find most recent screenshot
echo "Capture cancelled. Looking for most recent screenshot..." >&2
RECENT_SCREENSHOT=$(find "$SCREENSHOT_DIR" -name "screenshot_*.png" -type f -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -n1)

if [ -n "$RECENT_SCREENSHOT" ]; then
    echo "Using most recent screenshot: $RECENT_SCREENSHOT" >&2
    echo "$RECENT_SCREENSHOT"
    exit 0
else
    echo "Error: No screenshots found in $SCREENSHOT_DIR" >&2
    exit 1
fi