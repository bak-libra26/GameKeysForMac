import XCTest
@testable import GameKeysForMac

final class BlockRuleTests: XCTestCase {

    // MARK: - matches()

    func testMatchesExactKeyCodeAndModifiers() {
        let rule = BlockRule(keyCode: 12, modifierFlags: BlockRule.modCommand, displayName: "Cmd+Q")
        XCTAssertTrue(rule.matches(keyCode: 12, flags: BlockRule.modCommand))
    }

    func testDoesNotMatchDifferentKeyCode() {
        let rule = BlockRule(keyCode: 12, modifierFlags: BlockRule.modCommand, displayName: "Cmd+Q")
        XCTAssertFalse(rule.matches(keyCode: 13, flags: BlockRule.modCommand))
    }

    func testDoesNotMatchDifferentModifier() {
        let rule = BlockRule(keyCode: 12, modifierFlags: BlockRule.modCommand, displayName: "Cmd+Q")
        XCTAssertFalse(rule.matches(keyCode: 12, flags: BlockRule.modControl))
    }

    func testMatchesWithExtraModifiers() {
        // User presses Cmd+Shift+Q, rule is Cmd+Q — should still match (superset)
        let rule = BlockRule(keyCode: 12, modifierFlags: BlockRule.modCommand, displayName: "Cmd+Q")
        XCTAssertTrue(rule.matches(keyCode: 12, flags: BlockRule.modCommand | BlockRule.modShift))
    }

    func testMatchesNoModifierRule() {
        // F3 rule has no modifier — should match regardless of flags
        let rule = BlockRule(keyCode: 160, modifierFlags: 0, displayName: "F3")
        XCTAssertTrue(rule.matches(keyCode: 160, flags: 0))
        XCTAssertTrue(rule.matches(keyCode: 160, flags: BlockRule.modCommand))
    }

    func testDisabledRuleDoesNotMatch() {
        let rule = BlockRule(keyCode: 12, modifierFlags: BlockRule.modCommand, displayName: "Cmd+Q", isEnabled: false)
        XCTAssertFalse(rule.matches(keyCode: 12, flags: BlockRule.modCommand))
    }

    // MARK: - formatKeyName()

    func testFormatSingleModifier() {
        let name = BlockRule.formatKeyName(keyCode: 12, modifiers: BlockRule.modCommand)
        XCTAssertEqual(name, "Cmd + Q")
    }

    func testFormatMultipleModifiers() {
        let name = BlockRule.formatKeyName(keyCode: 12, modifiers: BlockRule.modCommand | BlockRule.modShift)
        XCTAssertEqual(name, "Shift + Cmd + Q")
    }

    func testFormatNoModifier() {
        let name = BlockRule.formatKeyName(keyCode: 122, modifiers: 0)
        XCTAssertEqual(name, "F1")
    }

    func testFormatArrowKeys() {
        XCTAssertEqual(BlockRule.formatKeyName(keyCode: 123, modifiers: BlockRule.modControl), "Ctrl + Left")
        XCTAssertEqual(BlockRule.formatKeyName(keyCode: 124, modifiers: BlockRule.modControl), "Ctrl + Right")
        XCTAssertEqual(BlockRule.formatKeyName(keyCode: 126, modifiers: BlockRule.modControl), "Ctrl + Up")
        XCTAssertEqual(BlockRule.formatKeyName(keyCode: 125, modifiers: BlockRule.modControl), "Ctrl + Down")
    }

    func testFormatSpecialKeys() {
        XCTAssertEqual(BlockRule.formatKeyName(keyCode: 49, modifiers: 0), "Space")
        XCTAssertEqual(BlockRule.formatKeyName(keyCode: 36, modifiers: 0), "Return")
        XCTAssertEqual(BlockRule.formatKeyName(keyCode: 48, modifiers: 0), "Tab")
        XCTAssertEqual(BlockRule.formatKeyName(keyCode: 53, modifiers: 0), "Esc")
        XCTAssertEqual(BlockRule.formatKeyName(keyCode: 51, modifiers: 0), "Delete")
    }

    func testFormatAllFKeys() {
        let fkeys: [(Int64, String)] = [
            (122, "F1"), (120, "F2"), (99, "F3"), (118, "F4"),
            (96, "F5"), (97, "F6"), (98, "F7"), (100, "F8"),
            (101, "F9"), (109, "F10"), (103, "F11"), (111, "F12")
        ]
        for (code, expected) in fkeys {
            XCTAssertEqual(BlockRule.formatKeyName(keyCode: code, modifiers: 0), expected)
        }
    }

    // MARK: - Codable

    func testCodableRoundTrip() throws {
        let rule = BlockRule(keyCode: 12, modifierFlags: BlockRule.modCommand, displayName: "Cmd+Q", label: "Test")
        let data = try JSONEncoder().encode(rule)
        let decoded = try JSONDecoder().decode(BlockRule.self, from: data)
        XCTAssertEqual(decoded.keyCode, rule.keyCode)
        XCTAssertEqual(decoded.modifierFlags, rule.modifierFlags)
        XCTAssertEqual(decoded.displayName, rule.displayName)
        XCTAssertEqual(decoded.label, rule.label)
        XCTAssertEqual(decoded.isEnabled, rule.isEnabled)
    }

    func testCodableArrayRoundTrip() throws {
        let rules = BlockRule.defaultRules
        let data = try JSONEncoder().encode(rules)
        let decoded = try JSONDecoder().decode([BlockRule].self, from: data)
        XCTAssertEqual(decoded.count, rules.count)
    }

    // MARK: - Constants

    func testModifierConstants() {
        XCTAssertEqual(BlockRule.modCommand, 0x100000)
        XCTAssertEqual(BlockRule.modControl, 0x40000)
        XCTAssertEqual(BlockRule.modOption, 0x80000)
        XCTAssertEqual(BlockRule.modShift, 0x20000)
        XCTAssertEqual(BlockRule.modifierMask, 0x00FF0000)
    }

    func testDefaultRulesCount() {
        XCTAssertEqual(BlockRule.defaultRules.count, 11)
    }

    func testDefaultRulesAllEnabled() {
        for rule in BlockRule.defaultRules {
            XCTAssertTrue(rule.isEnabled, "\(rule.displayName) should be enabled by default")
        }
    }

    func testDefaultRulesUniqueIDs() {
        let ids = BlockRule.defaultRules.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count, "All default rules should have unique IDs")
    }
}
