# KeyBindz agent handoff notes

Last updated: 2026-10-20. Keep this file current when changing guide behavior,
deployment, or live verification.

## Project and locations

- Repository: `/home/s3pp3ku/Projects/KeyBindz`
- Public remote: <https://github.com/s3pp3ku/KeyBindz> (default branch `keybindz`)
- Public docs, installation guide and screenshots were published on 2026-10-20.
  Push updates to `origin/keybindz`.
- Installed plugin (live copy): `~/.config/omarchy/plugins/io.github.s3pp3ku.keybindz/`
- User settings: `~/.config/omarchy/shell.json`
- Runtime state: `${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/keybindz/`
  (`catalog.json` and bridge-control backups; no keystroke history)
- This is an independent fork of Omakeez. Keep the plugin ID, bridge marker,
  protocol, and state directory independent from upstream.
- Historical upstream design documents are in `docs/upstream/`; they are not
  the current implementation guide.

The author's verification display is `eDP-1`: 1920x1200 physical, scale 1.6,
1200x750 logical. The current theme is Akira.

## Current state (2026-10-20)

- The working tree may contain uncommitted local changes. The installed plugin
  is a separate checkout and may also have been edited in place; update it
  explicitly for live testing.
- Default hold delay is 1000 ms. Super and Ctrl guides are enabled by default;
  Shift and Alt triggers are disabled. The delay options include Off.
- Keyboard guide look:
  - bound keys: charcoal `#141414` surfaces at the theme menu alpha;
  - unused keys: fully transparent with soft outlines and **no legends**;
  - key legends and command text are horizontally centered;
  - spacebar uses an 18 px legend and 14 px command with a 22 px legend band;
  - other full-height keys use 14 px legends and 10–11 px commands;
  - top-row half-height keys (Esc, F1–F12, PrtSc, Power, Delete) currently use
    an 11 px legend; bound ones show a compact 9 px command inline;
  - bottom half-height arrow keys keep their commands in the footer row.
- `SuperGuide.guideContent.y` uses a 27 logical px top base for keyboard mode.
  The Omarchy bar is 26 logical px tall, so this leaves roughly a 1 px gap.
  `guideTopOffset` adds to that for notches/camera housings.
- Recent fix: Esc and PrtSc were half-height and previously only showed their
  labels on the keycaps. They now show `System menu` / `Screenshot` inline
  because they are wide enough; the footer no longer duplicates those two.
- Last known test result (2026-10-20): keyboard 5, guide 7, service 13; the
  full `tests/shell/run all` suite and its static release checks pass.
- Public docs: `README.md` has the history, Omakeez credit, current screenshots
  and compatibility warning; `docs/INSTALL.md` has the detailed install,
  update, uninstall and troubleshooting guide. Current screenshots are
  `assets/screenshots/keyboard-guide.webp` and `settings-panel.webp`. Older
  upstream screenshots remain in `assets/screenshots/` but are not referenced
  by the current README.

## Architecture map

- `Service.qml` — settings, catalog loading/regeneration, bridge control,
  hardware detection, idle/lock/fullscreen state, and the
  `keybindz-feasibility` diagnostics IPC target.
- `SuperGuide.qml` — per-screen overlay windows, delay and visibility rules,
  header chip, top offset, and cards-vs-keyboard selection.
- `KeyboardGuide.qml` — physical keyboard drawing, key geometry, colors,
  legends, inline commands, footer pills, and hover detail.
- `KeyboardModel.js` — Zenbook UX3405CA US deck, key matching/aliases,
  short command descriptions, and extras.
- `GuideModel.js` — cards-mode ranking, canopy layout, eligibility, and delay
  modes.
- `Panel.qml` / `BarWidget.qml` — settings and bar UI.
- `bridge.lua`, `scripts/generate-catalog`, `scripts/bridge-control`,
  `scripts/detect-keyboard` — Hyprland bridge and catalog tooling.
- `tests/qml/` — model tests; `tests/shell/run` — shell/catalog/bridge tests.

## Build, test, deploy

Run the QML model tests from the repository:

```sh
cd /home/s3pp3ku/Projects/KeyBindz
for t in keyboard guide service; do
  env -u DISPLAY QT_QPA_PLATFORM=minimal \
    /usr/lib/qt6/bin/qmltestrunner -input tests/qml/tst_$t.qml -o -,txt
done
```

The full suite (checks that tracked worktree state does not change):

```sh
PATH=/usr/lib/qt6/bin:$PATH sh tests/shell/run all
```

Deploy only the files that changed. The installed plugin is what runs:

```sh
cd /home/s3pp3ku/Projects/KeyBindz
cp KeyboardGuide.qml SuperGuide.qml Service.qml ServiceModel.js GuideModel.js \
  Panel.qml manifest.json README.md CHANGELOG.md \
  ~/.config/omarchy/plugins/io.github.s3pp3ku.keybindz/
omarchy-restart-shell
```

`KeyboardGuide.qml` and `SuperGuide.qml` do not reliably hot-reload. Use a full
`omarchy-restart-shell` after changing them. Verify the installed copies:

```sh
for f in KeyboardGuide.qml SuperGuide.qml README.md CHANGELOG.md; do
  cmp -s "$f" "$HOME/.config/omarchy/plugins/io.github.s3pp3ku.keybindz/$f" \
    && echo "$f matches" || echo "$f MISMATCH"
done
```

## Live verification

The idle/screensaver layer can cover the guide. For a deliberate capture:

```sh
omarchy-toggle-idle          # disables idle while verifying
omarchy-debug-idle | sed -n '/== Idle IPC status ==/,/^$/p'
hyprctl clients -j | jq -r '.[] | select(.class=="org.omarchy.screensaver") | .pid'
```

Close any screensaver client if present, then hold Super for longer than the
1 s delay. A virtual `KEY_LEFTMETA` hold via evdev worked in earlier sessions
(`/tmp/opencode/hold_super.py`); virtual input does **not** reset Omarchy idle,
so disable idle for longer captures.

While the guide is visible:

```sh
omarchy-shell keybindz-feasibility diagnostics | jq -c \
  '{guideVisible,sampleCount,samplesMs}'
hyprctl layers -j | jq -r 'to_entries[] | .value.levels | to_entries[] |
  .key as $level | .value[]? |
  [$level,.namespace,.x,.y,.w,.h] | @tsv' | grep -E 'keybindz|omarchy-bar'
grim -o eDP-1 /tmp/opencode/guide.png
```

Check a logical 1200x750 thumbnail and a full-resolution top crop. Restore idle
afterward and confirm `enabled: true`, `stayAwake: false`.

## Layout and rendering gotchas

- The overlay is a full-width `PanelWindow` with `ExclusionMode.Ignore`.
  `guideContent.y` is measured from the top of the screen, not from the bar.
- The header chip sits above `KeyboardGuide`. The keyboard backdrop begins
  `8` px above the board and adds `headerChip.height + 12` px below the header.
  Raising the top base below 26 px will put guide content over the bar.
- Key rows use `KeyboardModel.zenbookKeys()`: full rows are `h = 1`, the top
  row is `h = 0.62`, and arrow keys are `h = 0.5`.
- `KeyboardGuide.qml` treats `h >= 0.6` as a top-row key that can show a compact
  inline command; `h < 0.6` keeps its commands in the footer. The footer
  filter must stay in sync with that threshold.
- Unused keys are intentionally fully transparent and legend-free. Do not
  reintroduce letters on blank keys without an explicit request.
- Commands use `Noto Sans`; legends use the theme mono font. Keycap radius is
  `unit * 0.04`, clamped to 2–4 px.
- The guide's backdrop blur comes from the Hyprland layer rule documented in
  `README.md`; transparent unused keys are meant to show the frosted desktop.

## Open items / cautions

- The top gap is 27 px and was verified on Akira/eDP-1: the header chip sits
  just below the 26 px bar. Re-check on themes with a taller bar; going below
  26 px will put guide content over the bar.
- The inline Esc/PrtSc commands were verified at 1200 logical width. Re-check
  narrower layouts: the top-row command uses one line with fit/elide, and long
  commands remain available in hover detail.
- Keep `README.md`, `docs/INSTALL.md` and `CHANGELOG.md` aligned with
  user-visible guide changes.
- Re-run the installed-copy comparison after any deploy.
- Before publishing or updating, review `git status`, commit intentionally, and
  do not let the plugin updater fast-forward over local work.
