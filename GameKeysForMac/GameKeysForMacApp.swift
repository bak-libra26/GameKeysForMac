import SwiftUI

@main
struct GameKeysForMacApp: App {
    @StateObject private var appState: AppState
    @StateObject private var gameMode: GameModeManager

    init() {
        let state = AppState()
        _appState = StateObject(wrappedValue: state)
        _gameMode = StateObject(wrappedValue: GameModeManager(appState: state))
    }

    var body: some Scene {
        MenuBarExtra {
            PopoverView(gameMode: gameMode, appState: appState)
                .onAppear {
                    gameMode.registerGlobalHotkey()
                }
        } label: {
            Image(systemName: appState.isGameModeEnabled ? "shield.fill" : "shield")
        }

        Window("GameKeys for Mac", id: "settings") {
            SettingsView(appState: appState, gameMode: gameMode)
        }
        .defaultSize(width: 580, height: 420)
        .windowResizability(.contentSize)
    }
}
