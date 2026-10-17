# Trick-or-Treat Town - Godot 4 demo

A tiny playable demo for the Trick-or-Treat Town asset pack (2-in-1: cozy town + Halloween,
16x16 pixel art by Spaceyyy). Walk the street at night, step into the haunted house and the
candy shop, and flip the whole town from night to day.

## The art is not in this repo
This repo ships only code. The pixel art lives in your copy of the pack. To play:

1. Unzip the pack (the free Lite or the full Complete) and copy its folders into `godot/assets/`
   so you get `assets/tiles/`, `assets/sprites/`, `assets/characters/` and `assets/godot/`.
2. Build the scenes for the art you have (it is tolerant: it uses whatever is present):

       godot --headless --path godot --script ../godot_build/build.gd

3. Open `godot/project.godot` in Godot 4.3 or newer and press F5.

With the Complete you get the street, the haunted house, the candy shop and the day/night
switch. With the free Lite you get the street and the day/night switch; the interior doors
simply don't appear, because their art isn't in the Lite.

## Controls
- Arrow keys or WASD to walk.
- N, or the on-screen "Day / Night" button, to switch day and night.
- Walk into a lit doorway to go inside; walk out the bottom door to return to the street.

## How it is built
- `godot_build/escenas.json`: the contents of every scene, each texture pointing at
  `res://assets/...` (the folder where you unzip the pack).
- `godot_build/build.gd`: builds `scenes/*.tscn` from that JSON, skipping anything whose art
  is missing. That is what lets the same project run on both the Lite and the Complete.
- `scripts/level.gd`: places the player and camera, the on-screen button and the day/night.
- `scripts/demo.gd` (autoload): input actions, the day/night state, and a small autopilot
  (`-- --autopilot`) used to test the demo without a window.
- `scripts/player.gd`, `scripts/door.gd`.

Code license: MIT (see LICENSE-code.txt). Art: Trick-or-Treat Town license (see the pack).
Made by Spaceyyy.
