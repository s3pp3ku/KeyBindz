# Installing KeyBindz

KeyBindz is an Omarchy bar widget and service. It needs Omarchy's Lua-based
Hyprland configuration and Quickshell. The maintainer's tested environment is
Omarchy 4.0.5 with Hyprland 0.56.2.

## Before you begin

1. Disable Omakeez if it is installed. KeyBindz has its own plugin ID, bridge
   marker, event protocol and state directory; running both is not supported.
2. Make sure your Hyprland configuration is writable by your user. The setup
   panel reviews the exact managed bridge block before applying it.
3. Optional but recommended: make a backup or commit your dotfiles before
   enabling the bridge.

## Add and enable

```sh
omarchy plugin add https://github.com/s3pp3ku/KeyBindz.git --enable
```

If the bar does not refresh immediately:

```sh
omarchy-shell shell rescanPlugins
omarchy-restart-shell
```

Open the KeyBindz keyboard icon in the bar. The setup panel shows:

- the guide view (Keyboard, Cards or Detect);
- the hold delay and top offset;
- which held modifiers open a guide;
- the Hyprland bridge status and the exact block that will be added.

Review the bridge block and choose **Enable visual guide**. Shortcuts continue to
work normally after the bridge is installed.

## Frosted backdrop

The guide uses a transparent layer. To get the frosted appearance, add this to
`~/.config/hypr/looknfeel.lua`:

```lua
hl.layer_rule({
  match = { namespace = "^keybindz-guide$" },
  blur = true,
  xray = false,
  ignore_alpha = 0.01,
})
```

Reload Hyprland:

```sh
hyprctl reload
```

Blur must also be enabled in the compositor settings. Without the rule the guide
still works, but the desktop behind it is not blurred.

## Verify

Hold Super for at least the configured delay. The guide should appear on the
focused monitor. Useful checks:

```sh
omarchy-shell keybindz-feasibility diagnostics
hyprctl configerrors
```

The diagnostics should show the catalog ready and the integration enabled. If
the guide does not appear, check the delay setting, fullscreen behavior, the
idle/screensaver state, and whether the selected modifier is enabled.

## Configure

Open the KeyBindz panel from the bar. The same values can be edited in
`~/.config/omarchy/shell.json` under the plugin's entry:

```json
{
  "id": "io.github.s3pp3ku.keybindz",
  "guideView": "keyboard",
  "guideDelayMs": 1000,
  "guideTopOffset": 0,
  "guideSuperEnabled": true,
  "guideCtrlEnabled": true,
  "guideShiftEnabled": false,
  "guideAltEnabled": false,
  "showInFullscreen": false
}
```

`guideView` is `keyboard` for the tested Zenbook deck or `cards` for the generic
fallback. Use **Detect** in the panel to re-run hardware and layout detection.

## Update

```sh
omarchy plugin update io.github.s3pp3ku.keybindz --yes
omarchy-restart-shell
```

The updater uses a fast-forward Git merge. Commit or back up local changes
before updating.

## Uninstall

1. Open the KeyBindz panel and choose **Disable visual guide**. This removes the
   managed bridge block.
2. Remove the plugin:

```sh
omarchy plugin remove io.github.s3pp3ku.keybindz
```

3. If you added the blur rule, remove it from
   `~/.config/hypr/looknfeel.lua` and reload Hyprland.
4. Optional: remove the runtime state directory:

```sh
rm -rf "${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/keybindz"
```

Do not delete the state directory while the guide is enabled if you may want the
bridge backups; disable the guide first.

## Troubleshooting

### The guide does not appear

- Check that the selected modifier root is enabled.
- Check the hold delay; the default is 1 s.
- If a fullscreen app is focused, enable **Fullscreen** in the panel or leave it
  off by design.
- The lock screen and Omarchy's credential prompt suppress the guide.
- The idle/screensaver layer may cover the guide while the session is idle.
- Run `omarchy-shell keybindz-feasibility diagnostics` and `hyprctl configerrors`.

### The keyboard does not match my laptop

The physical keyboard overlay is only tested on the ASUS Zenbook 14 UX3405CA
with a US layout. Use **Cards** or **Detect** in the settings panel. Do not
assume the key geometry maps to another deck; reports and layout patches are
welcome, but cross-device support is not guaranteed.

### Blur is missing

Confirm that the layer rule uses the exact namespace `keybindz-guide`, that blur
is enabled in the compositor, and that Hyprland was reloaded. A transparent guide
without blur is expected when the rule is absent.

### The bridge will not enable

The setup panel validates the target path, ownership, symlinks and exact diff
before writing. Review the error in the panel and run:

```sh
hyprctl configerrors
```

Do not edit the managed block by hand. Disable the guide first if you need to
remove it manually.

### Omakeez is still installed

Disable Omakeez before using KeyBindz. The two plugins have separate bridge
markers and state directories, but running both shortcut observers is
unsupported.

## Privacy

KeyBindz does not store keystroke history and does not make network requests.
The bridge reduces input to the allowlisted modifier/key transitions needed for
the guide. See [SECURITY.md](upstream/SECURITY.md) for the upstream security
model.
