# KeyBindz

A theme-aware keyboard shortcut guide for Omarchy, maintained by **s3pp3ku**.
Hold Super for half a second to see your registered shortcuts on a frosted
keyboard overlay. Quick shortcuts finish without showing the guide.

KeyBindz is an independent MIT-licensed fork of
[Omakeez by cyprusad](https://github.com/cyprusad/omakeez). It retains the upstream
history and copyright; the keyboard view and local refinements are maintained
here. Archived upstream design notes live in [docs/upstream](docs/upstream).

## Features

- Physical keyboard view for the ASUS Zenbook 14 UX3405CA US layout, with
  automatic hardware/layout detection and a cards fallback for other keyboards.
- Theme menu colors, control borders, gradients, corner rounding and opacity.
- A frosted backdrop, faint unused-key outlines and readable shortcut labels.
- A 500 ms default delay, with Instant, 80, 150, 250 and 500 ms options or Off.
- Super and Ctrl guides enabled by default; Shift and Alt triggers disabled.
  Add other modifiers while holding an enabled starting key to change the guide.
- The guide follows the focused monitor and stays hidden over fullscreen apps
  by default. It never changes your actual shortcuts.
- No network client, keystroke history, statistics or `/dev/input` access.

## Install

Requires Omarchy's Lua-based Hyprland configuration and Quickshell. The fork was
validated on Omarchy 4.0.5 and Hyprland 0.56.2.

```sh
omarchy plugin add https://github.com/s3pp3ku/KeyBindz.git --enable
```

Open the KeyBindz bar widget and enable the visual guide. Its setup panel shows
the small Hyprland bridge block before applying it.

For the frosted effect, add this to `~/.config/hypr/looknfeel.lua` and reload
Hyprland. Blur must be enabled in your compositor settings.

```lua
hl.layer_rule({
  match = { namespace = "^keybindz-guide$" },
  blur = true,
  xray = false,
  ignore_alpha = 0.01,
})
```

Disable Omakeez before switching; KeyBindz uses its own plugin ID, bridge marker,
event protocol and state directory. The initial migration on the author's
machine preserves the existing widget placement and settings.

## Configuration and updates

Preferences live in KeyBindz's entry in `~/.config/omarchy/shell.json`, separate
from the repository. Drawer-hosted widgets use the top-level `plugins` entry.
Example:

```json
{
  "id": "io.github.s3pp3ku.keybindz",
  "guideView": "keyboard",
  "guideDelayMs": 500,
  "guideShiftEnabled": false,
  "guideAltEnabled": false,
  "showInFullscreen": false
}
```

The frosted backdrop follows the theme's menu scrim; shortcut backgrounds follow
the menu background with an 88% opacity minimum. Held-key borders keep the menu
selection highlight even when the theme uses a gradient for menu frames.

```sh
omarchy plugin update io.github.s3pp3ku.keybindz --yes
```

Updates now come from this fork. Upstream Omakeez changes are incorporated
explicitly rather than replacing the custom keyboard implementation. Commit
source changes before updating; the updater uses a fast-forward Git merge and
refuses conflicting local changes.

Runtime metadata lives in `${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/keybindz/`.
It contains the generated shortcut catalog and bridge-control backups, with no
activity history. Hardware detection reads DMI/sysfs metadata and the active
Hyprland keyboard layout; it does not read input-device events.

## Development

```sh
PATH=/usr/lib/qt6/bin:$PATH sh tests/shell/run all
```

The tests cover catalog generation, bridge behavior, safe configuration changes,
guide filtering, keyboard layout and hardware detection. Keep the MIT license
and upstream attribution when redistributing.
