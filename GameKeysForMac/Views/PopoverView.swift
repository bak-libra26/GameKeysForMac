import SwiftUI

struct PopoverView: View {
    @ObservedObject var gameMode: GameModeManager
    @ObservedObject var appState: AppState
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Group {
            Button {
                gameMode.toggleGameMode()
            } label: {
                HStack {
                    Image(systemName: appState.isGameModeEnabled ? "checkmark" : "")
                        .frame(width: 14)
                    Text(appState.isGameModeEnabled ? L.gameModeOn : L.gameModeOff)
                }
            }
            .keyboardShortcut("g", modifiers: [.control, .option])

            Text(L.hotkeyHint)
                .font(.caption)
                .foregroundColor(.secondary)

            Divider()

            Toggle(L.keyBlock, isOn: $appState.isKeyBlockEnabled)
            Toggle(L.dnd, isOn: $appState.isDNDEnabled)
            Toggle(L.sleepPrevention, isOn: $appState.isSleepPreventionEnabled)
            Toggle(L.hotCorners, isOn: $appState.isHotCornersDisabled)
            Toggle(L.cursorShake, isOn: $appState.isCursorShakeDisabled)
            Toggle(L.fnBlock, isOn: $appState.isFnBlockEnabled)

            Divider()

            Button(L.settings) {
                openWindow(id: "settings")
                NSApp.activate(ignoringOtherApps: true)
            }

            Button(L.about) {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.orderFrontStandardAboutPanel(nil)
            }

            Divider()

            Button(L.quit) {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}
