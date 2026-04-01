# GameKeys for Mac

macOS menu bar app that blocks system shortcuts during gameplay.

## Build

```bash
xcodebuild -scheme GameKeysForMac -configuration Release build
```

## Architecture

```
Models/     — Data models (AppState, BlockRule, Localization)
Managers/   — Business logic (GameModeManager, SystemManager)
Views/      — SwiftUI views (PopoverView, SettingsView, MenuBarIcon)
```

- **AppState** — Central state store, UserDefaults persistence
- **GameModeManager** — CGEvent Tap for key blocking, global hotkey, Combine observer for rule sync
- **SystemManager** — Sleep prevention (IOPMAssertion), cursor shake control
- **BlockRule** — Key matching, formatting, modifier constants

## Conventions

- Swift 5, macOS 14.0+ deployment target
- `final class` for ObservableObject types
- `private` by default for View components
- Design tokens in `DS` enum (SettingsView)
- Localization via `L` enum (not .strings files)
- `MARK:` comments for section organization

## Key Decisions

- Native macOS menu style for popover (not custom window)
- CGEvent Tap only intercepts keyDown (not keyUp) to avoid game input bugs
- MenuBarIcon rendered as cached NSImage (not SF Symbol)
- DND/Fn/Hot Corners features removed from v1 (macOS API limitations)
- F3=160, F4=131 are media key codes (different from kVK_F3=99, kVK_F4=101)

## Testing

Test files in `GameKeysForMacTests/`. Add test target in Xcode:
File > New > Target > Unit Testing Bundle > GameKeysForMacTests

```bash
xcodebuild test -scheme GameKeysForMac
```
