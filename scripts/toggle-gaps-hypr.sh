#!/bin/bash
# Toggle Hyprland window gaps between 10px and 0px
CURRENT=$(hyprctl getoption general:gaps_out | head -1 | awk '{print $2}')

if [ "$CURRENT" = "10" ]; then
    hyprctl keyword general:gaps_out 0
    hyprctl keyword general:gaps_in 0
else
    hyprctl keyword general:gaps_out 10
    hyprctl keyword general:gaps_in 5
fi
