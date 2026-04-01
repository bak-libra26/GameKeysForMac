import XCTest
@testable import GameKeysForMac

final class LocalizationTests: XCTestCase {

    func testKoreanStrings() {
        L.lang = .korean
        XCTAssertEqual(L.gameModeOff, "게임 모드 켜기")
        XCTAssertEqual(L.gameModeOn, "게임 모드 끄기")
        XCTAssertEqual(L.quit, "종료")
        XCTAssertEqual(L.settings, "설정...")
    }

    func testEnglishStrings() {
        L.lang = .english
        XCTAssertEqual(L.gameModeOff, "Turn On Game Mode")
        XCTAssertEqual(L.gameModeOn, "Turn Off Game Mode")
        XCTAssertEqual(L.quit, "Quit")
        XCTAssertEqual(L.settings, "Settings...")
    }

    func testHotkeyHintIsLanguageIndependent() {
        L.lang = .korean
        let ko = L.hotkeyHint
        L.lang = .english
        let en = L.hotkeyHint
        XCTAssertEqual(ko, en, "Hotkey hint should be language-independent")
        XCTAssertEqual(ko, "Ctrl + Opt + G")
    }

    func testDefaultRuleLabelsMatchLanguage() {
        L.lang = .korean
        let koRules = BlockRule.defaultRules
        XCTAssertEqual(koRules.first?.label, "앱 종료 방지")

        L.lang = .english
        let enRules = BlockRule.defaultRules
        XCTAssertEqual(enRules.first?.label, "Prevent App Quit")
    }

    func testAllLanguageCases() {
        XCTAssertEqual(AppLanguage.allCases.count, 2)
        XCTAssertEqual(AppLanguage.korean.displayName, "한국어")
        XCTAssertEqual(AppLanguage.english.displayName, "English")
    }
}
