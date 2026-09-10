# ProjectDogfight

ProjectDogfight is a 2D aircraft combat project built with Godot 4.7 and
LimboAI 1.8. The repository is organized by gameplay responsibility so scenes,
scripts, resources, tests, and third-party examples remain clearly separated.

## Project structure

```text
assets/       Source art, audio, fonts, and application branding
game/         Runtime scenes and scripts grouped by gameplay feature
resources/    Shared data resources and themes
tests/        Integration and manual test scenes
third_party/  Preserved third-party examples and their licenses
docs/         Project notes, migration guides, and change logs
```

The application starts at `game/ui/menus/main_menu.tscn`. The playable scene is
`game/core/main_game.tscn`.

Runtime code under `game/` is divided into:

- `core`: game-level scenes and managers
- `autoload`: global game status, spawning, and sound services
- `camera`: camera shake and game-feel components
- `ai`: behavior tasks and production enemy behavior trees
- `aircraft`: shared aircraft code, player, enemies, and formations
- `combat`: bullets, missiles, and weapons
- `world`: backgrounds, spawning, and pickups
- `ui`: HUD, input, menus, and visual effects

## Naming rules

- Project-owned directories and files use lowercase `snake_case`.
- GDScript identifiers use `snake_case`; classes and node types use
  `PascalCase`.
- Third-party source asset filenames are preserved when ownership or upstream
  naming is significant.
- Godot `.uid` files are committed. Generated `.import` files are ignored.

## Autoloads

- `GameFeel`: camera feedback service
- `GameStatusServer`: game state service
- `SoundManager`: audio service
- `SpawnServer`: runtime spawning service

## Tests

Automated integration scenes live in `tests/integration`; interactive checks
live in `tests/manual`. Run a test scene with the same Godot 4.7 LimboAI build
used by the project, for example:

```sh
godot --headless --path . --quit-after 5 tests/integration/test_touch_hud_layer.tscn
godot --headless --path . --quit-after 5 tests/integration/test_virtual_joystick_migration.tscn
```

Manual coverage includes the official `VirtualJoystick` touch behavior and the
enemy test scene.
