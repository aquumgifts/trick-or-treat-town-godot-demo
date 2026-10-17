# Trick-or-Treat Town — Godot 4 demo

A tiny, free, playable demo for the **Trick-or-Treat Town** asset pack (a 2-in-1 of a cozy
modern town and Halloween, 16x16 pixel art by Spaceyyy). Walk the street on trick-or-treat
night, step into the haunted house and the candy shop, and flip the whole town from night to
day.

This repo ships **only the code** (MIT). The pixel art lives in your copy of the pack, which
you unzip into `godot/assets/`. That is why the project declares no AI-generated code on its
store page — the demo's source is here, in the open.

## See it
Screenshots and animated previews are on the itch.io page's gallery:
https://aquumgifts.itch.io/cozy-town-halloween

## Play it
1. **Download Trick-or-Treat Town from itch.io** (the free Lite or the full Complete):
   https://aquumgifts.itch.io/cozy-town-halloween
2. **Unzip it into `godot/assets/`** so you get `assets/tiles/`, `assets/sprites/`,
   `assets/characters/` and `assets/godot/`.
3. **Build the scenes** for the art you have (the build is tolerant — it uses whatever is
   present):

       godot --headless --path godot --script res://../godot_build/build.gd

4. **Open `godot/project.godot` in Godot 4.7** (4.3 or newer) and press F5.

With the Complete you get the street, the haunted house, the candy shop and the day/night
switch. With the free Lite you get the night street and the day/night switch; the interior
doors simply don't appear, because their art isn't in the Lite.

## Controls
- Arrow keys or WASD to walk.
- `N`, or the on-screen "Day / Night" button, to switch day and night.
- Walk into a lit doorway to go inside; walk out the bottom door to return to the street.

## How it is built
- `godot_build/escenas.json` — the contents of every scene, each texture pointing at
  `res://assets/...` (the folder where you unzip the pack).
- `godot_build/build.gd` — builds `godot/scenes/*.tscn` from that JSON, skipping anything whose
  art is missing. That is what lets the same project run on both the Lite and the Complete.
- `godot/scripts/level.gd` — places the player and camera, the on-screen button and the
  day/night state.
- `godot/scripts/demo.gd` (autoload) — input actions, the day/night state, and a small
  autopilot (`-- --autopilot`) used to test the demo without a window.
- `godot/scripts/player.gd`, `godot/scripts/door.gd`.

## License
Code: MIT (see `LICENSE`). The pixel art you unzip into `assets/` is **not** covered by this
license — it is part of the Trick-or-Treat Town pack (see the pack's own LICENSE.txt).

Made by Spaceyyy.
