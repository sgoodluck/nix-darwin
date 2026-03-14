#!/bin/bash
# Toggle aerospace window gaps between 10px and 0px
CONFIG="$HOME/.config/aerospace/aerospace.toml"

# Resolve symlink to modify the actual file
if [ -L "$CONFIG" ]; then
    CONFIG=$(readlink "$CONFIG")
fi

if grep -q 'inner.horizontal = 0' "$CONFIG"; then
    sed -i '' 's/inner.horizontal = 0/inner.horizontal = 10/' "$CONFIG"
    sed -i '' 's/inner.vertical =   0/inner.vertical =   10/' "$CONFIG"
    sed -i '' 's/outer.left =       0/outer.left =       10/' "$CONFIG"
    sed -i '' 's/outer.bottom =     0/outer.bottom =     10/' "$CONFIG"
    sed -i '' 's/outer.top =        0/outer.top =        10/' "$CONFIG"
    sed -i '' 's/outer.right =      0/outer.right =      10/' "$CONFIG"
else
    sed -i '' 's/inner.horizontal = 10/inner.horizontal = 0/' "$CONFIG"
    sed -i '' 's/inner.vertical =   10/inner.vertical =   0/' "$CONFIG"
    sed -i '' 's/outer.left =       10/outer.left =       0/' "$CONFIG"
    sed -i '' 's/outer.bottom =     10/outer.bottom =     0/' "$CONFIG"
    sed -i '' 's/outer.top =        10/outer.top =        0/' "$CONFIG"
    sed -i '' 's/outer.right =      10/outer.right =      0/' "$CONFIG"
fi

aerospace reload-config
