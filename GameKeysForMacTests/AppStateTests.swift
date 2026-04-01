import XCTest
@testable import GameKeysForMac

final class AppStateTests: XCTestCase {

    override func setUp() {
        // 테스트 간 UserDefaults 격리
        let defaults = UserDefaults.standard
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix("GK.") {
            defaults.removeObject(forKey: key)
        }
    }

    func testDefaultValues() {
        let state = AppState()
        XCTAssertTrue(state.isKeyBlockEnabled)
        XCTAssertTrue(state.isSleepPreventionEnabled)
        XCTAssertFalse(state.isCursorShakeDisabled)
        XCTAssertFalse(state.launchAtLogin)
        XCTAssertFalse(state.isGameModeEnabled)
    }

    func testTogglePersistence() {
        let state1 = AppState()
        state1.isKeyBlockEnabled = false

        let state2 = AppState()
        XCTAssertFalse(state2.isKeyBlockEnabled)

        // Cleanup
        state2.isKeyBlockEnabled = true
    }

    func testBlockRulesPersistence() throws {
        let state1 = AppState()
        let customRule = BlockRule(keyCode: 999, modifierFlags: 0, displayName: "Test", label: "Test Rule")
        state1.blockRules.append(customRule)

        let state2 = AppState()
        XCTAssertTrue(state2.blockRules.contains(where: { $0.keyCode == 999 }))

        // Cleanup
        state2.blockRules = BlockRule.defaultRules
    }

    func testLanguagePersistence() {
        let state1 = AppState()
        state1.language = .english

        let state2 = AppState()
        XCTAssertEqual(state2.language, .english)

        // Cleanup
        state2.language = .korean
    }

    func testLanguageUpdatesLocalization() {
        let state = AppState()
        state.language = .english
        XCTAssertEqual(L.lang, .english)

        state.language = .korean
        XCTAssertEqual(L.lang, .korean)
    }
}
