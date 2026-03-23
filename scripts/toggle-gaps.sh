#!/bin/bash
# Toggle aerospace window gaps between 10px and 0px
SRC="$HOME/nix/dotfiles/aerospace/aerospace.toml"
DEST="$HOME/.config/aerospace/aerospace.toml"

if grep -q 'inner.horizontal = 0' "$SRC"; then
    sed -i '' 's/inner.horizontal = 0/inner.horizontal = 10/' "$SRC"
    sed -i '' 's/inner.vertical =   0/inner.vertical =   10/' "$SRC"
    sed -i '' 's/outer.left =       0/outer.left =       10/' "$SRC"
    sed -i '' 's/outer.bottom =     0/outer.bottom =     10/' "$SRC"
    sed -i '' 's/outer.top =        0/outer.top =        10/' "$SRC"
    sed -i '' 's/outer.right =      0/outer.right =      10/' "$SRC"
else
    sed -i '' 's/inner.horizontal = 10/inner.horizontal = 0/' "$SRC"
    sed -i '' 's/inner.vertical =   10/inner.vertical =   0/' "$SRC"
    sed -i '' 's/outer.left =       10/outer.left =       0/' "$SRC"
    sed -i '' 's/outer.bottom =     10/outer.bottom =     0/' "$SRC"
    sed -i '' 's/outer.top =        10/outer.top =        0/' "$SRC"
    sed -i '' 's/outer.right =      10/outer.right =      0/' "$SRC"
fi

# Copy over the nix store symlink so aerospace reads the updated config
cp "$SRC" "$DEST"
aerospace reload-config
