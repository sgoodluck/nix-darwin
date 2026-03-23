---
phase: 260323-gs6
plan: 01
subsystem: nixos-hyprland
tags: [hyprland, nixos, display-scaling, unfree-packages]
dependency_graph:
  requires: []
  provides: [hyprland-native-scale, nixos-unfree-packages]
  affects: [x1nano-display, nix-flake-eval]
tech_stack:
  added: []
  patterns: [nixos-module-config]
key_files:
  created: []
  modified:
    - dotfiles/hypr/hyprland.conf
    - flake.nix
decisions:
  - "Changed monitor scale from 1.8 to 1.0 for native resolution display"
  - "Added allowUnfree as first NixOS module for early evaluation"
metrics:
  duration: "~2 min"
  completed: "2026-03-23T19:10:50Z"
---

# Quick Task 260323-gs6: Fix Gesture/Display/Unfree Issues Summary

Updated Hyprland display scale to native 1.0 and added allowUnfree to NixOS flake config for proprietary package support.

## Completed Tasks

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Update Hyprland config - gestures and display scale | c052329 | dotfiles/hypr/hyprland.conf |
| 2 | Ensure allowUnfree propagates in flake | 9e3468c | flake.nix |

## Changes Made

### Task 1: Hyprland Display Scale
- Changed `monitor = eDP-1, preferred, auto, 1.8` to `monitor = eDP-1, preferred, auto, 1.0`
- Updated lid switch handler to use 1.0 scale instead of 1.8
- Changed `GDK_SCALE` from 2 to 1 to match new monitor scale
- Gestures block retained as-is (syntax is correct for modern Hyprland)

### Task 2: allowUnfree in Flake
- Added `{ nixpkgs.config.allowUnfree = true; }` as first module in mkNixosConfig
- Ensures unfree packages (proprietary drivers, etc.) work during flake evaluation

## Deviations from Plan

None - plan executed exactly as written.

## Verification Results

All success criteria met:
- Monitor scale changed from 1.8 to 1.0
- Lid switch handler uses 1.0 scale
- GDK_SCALE updated to 1
- allowUnfree explicitly set in flake.nix for NixOS config

## Self-Check: PASSED

Files verified:
- FOUND: dotfiles/hypr/hyprland.conf (contains `monitor = eDP-1, preferred, auto, 1.0`)
- FOUND: flake.nix (contains `allowUnfree = true`)

Commits verified:
- FOUND: c052329
- FOUND: 9e3468c
