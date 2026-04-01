import SwiftUI

@main
struct GameKeysForMacApp: App {
    @StateObject private var appState: AppState
    @StateObject private var gameMode: GameModeManager

    init() {
        let state = AppState()
        let manager = GameModeManager(appState: state)
        manager.registerGlobalHotkey()
        _appState = StateObject(wrappedValue: state)
        _gameMode = StateObject(wrappedValue: manager)
    }

    var body: some Scene {
        MenuBarExtra {
            PopoverView(gameMode: gameMode, appState: appState)
        } label: {
            Image(nsImage: MenuBarIcon.image(isActive: appState.isGameModeEnabled))
        }

        Window("GameKeys for Mac", id: "settings") {
            SettingsView(appState: appState, gameMode: gameMode)
        }
        .defaultSize(width: 580, height: 420)
        .windowResizability(.contentSize)
    }
}
