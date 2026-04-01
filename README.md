# GameKeys for Mac

A macOS menu bar app that blocks system shortcuts and behaviors that interrupt gameplay.

Fills the gaps that macOS Game Mode doesn't cover.

> MapleStory 하다가 `Cmd + Q` 잘못 눌러서 게임이 꺼지거나, `Ctrl + 방향키`로 Spaces가 전환된 경험이 있다면 이 앱이 딱 그 용도입니다.

### 한국어 요약

macOS에는 Game Mode가 있지만 시스템 단축키 충돌은 해결하지 않습니다. GameKeys for Mac은 게임 중 `Cmd+Q`, `Cmd+Tab`, `Ctrl+방향키`, `F3`, `F4` 같은 시스템 단축키를 차단해서 게임 플레이가 방해받지 않게 합니다. 메뉴바 아이콘 클릭 한 번으로 켜고 끌 수 있고, 차단할 키를 직접 설정할 수 있습니다.

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
- Add custom shortcuts via **Settings > Block Keys > Add Key**

### System Controls

- **Prevent Display Sleep** — Keeps the display awake while Game Mode is on (uses IOPMAssertion)
- **Disable Cursor Shake-to-Locate** — Prevents the cursor from enlarging when you shake the mouse (writes to NSGlobalDomain via UserDefaults)

### How to Use

1. Click the shield icon in the menu bar
2. Select **Turn On Game Mode**
3. Done. All blocking is applied at once.

Toggle anywhere with the global hotkey `Ctrl + Opt + G`.

## Screenshots

### Menu Bar Popover

Game Mode ON/OFF + individual feature toggles

<!-- TODO: Add screenshot image -->

### Settings

Block Keys / System Options / General (including language)

<!-- TODO: Add screenshot image -->

## Install

1. Download **`GameKeysForMac-1.0.0.pkg`** from [Releases](https://github.com/bak-libra26/GameKeysForMac/releases)

2. Open **Terminal** and remove the quarantine flag:

   ```bash
   xattr -cr ~/Downloads/GameKeysForMac-1.0.0.pkg
   ```

3. Double-click the `.pkg` file and follow the installer

4. Launch **GameKeys for Mac** from Applications

5. Grant **Accessibility** permission when prompted
   - System Settings > Privacy & Security > Accessibility > Enable **GameKeysForMac**

> **Why is step 2 needed?** This app is open source and not signed with an Apple Developer certificate ($99/year). macOS blocks unsigned apps by default. The `xattr -cr` command removes the quarantine flag so the installer can run normally. This is safe — you can review the full source code in this repository.

## Requirements

- macOS 14.0+

## Build

```bash
git clone https://github.com/bak-libra26/GameKeysForMac.git
cd GameKeysForMac
xcodebuild -scheme GameKeysForMac -configuration Release build
```

Or open `GameKeysForMac.xcodeproj` in Xcode and build.

Requires **Xcode 15+** (Swift 5.9, macOS 14 SDK).

## Why?

macOS Sonoma introduced Game Mode, but it:

- Doesn't block system shortcuts (`Cmd+Q`, `Cmd+Tab`, `Ctrl+Arrow`, etc.)
- Doesn't prevent display sleep during gameplay
- Has no settings or customization

Built to solve real frustrations for Mac gamers playing MapleStory, League of Legends, CS2, and more.

## Language Support

- Korean (한국어)
- English

Auto-detected from system language. Changeable in Settings > General.

## License

MIT License
