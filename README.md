# GameKeys for Mac

A macOS menu bar app that blocks system shortcuts and behaviors that interrupt gameplay.

Fills the gaps that macOS Game Mode doesn't cover.

## Features

### System Shortcut Blocking
- `Cmd + Q` — Prevent accidental app quit
- `Cmd + Tab` — Prevent app switching
- `Cmd + H` — Prevent app hiding
- `Cmd + M` — Prevent minimize
- `Cmd + Space` — Prevent Spotlight
- `Ctrl + Arrow Keys` — Prevent Spaces switching
- `F3` — Prevent Mission Control
- `F4` — Prevent Launchpad
- Add custom shortcuts

### System Controls
- **Do Not Disturb (DND)** — Auto-enable when gaming
- **Disable Hot Corners** — Block mouse corner actions
- **Prevent Display Sleep** — Stop sleep timer
- **Disable Cursor Shake-to-Locate** — Prevent cursor enlargement
- **Block Fn/Globe Emoji Picker**

### How to Use
1. Click the shield icon in the menu bar
2. Select **Turn On Game Mode**
3. Done. All blocking is applied at once.

Toggle anywhere with the global hotkey `Ctrl + Opt + G`.

## Screenshots

### Menu Bar Popover
Game Mode ON/OFF + individual feature toggles

### Settings
Block Keys / System Options / General (including language)

## Requirements

- macOS 14.0+
- Accessibility permission required (System Settings > Privacy & Security > Accessibility)

## Build

```bash
git clone https://github.com/bak-libra26/GameKeysForMac.git
cd GameKeysForMac
xcodebuild -scheme GameKeysForMac -configuration Release build
```

Or open `GameKeysForMac.xcodeproj` in Xcode and build.

## Why?

macOS Sonoma introduced Game Mode, but it:
- Doesn't block system shortcuts
- Doesn't disable Hot Corners
- Doesn't prevent Dock/menu bar auto-show
- Has no settings or customization

Built to solve real frustrations for Mac gamers playing MapleStory, League of Legends, CS2, and more.

## Language Support

- Korean (한국어)
- English

Auto-detected from system language. Changeable in Settings > General.

## License

MIT License
