import Foundation
import Carbon.HIToolbox

struct BlockRule: Codable, Hashable, Identifiable {
    let id: UUID
    var keyCode: Int64
    var modifierFlags: UInt64
    var displayName: String
    var label: String
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        keyCode: Int64,
        modifierFlags: UInt64 = 0,
        displayName: String,
        label: String = "",
        isEnabled: Bool = true
    ) {
        self.id = id
        self.keyCode = keyCode
        self.modifierFlags = modifierFlags
        self.displayName = displayName
        self.label = label
        self.isEnabled = isEnabled
    }

    // MARK: - Matching

    func matches(keyCode: Int64, flags: UInt64) -> Bool {
        guard isEnabled else { return false }
        if modifierFlags == 0 {
            return self.keyCode == keyCode
        }
        return self.keyCode == keyCode && (flags & modifierFlags) == modifierFlags
    }

    // MARK: - Key Name Formatting

    static func formatKeyName(keyCode: Int64, modifiers: UInt64) -> String {
        var parts: [String] = []
        if modifiers & modControl != 0 { parts.append("Ctrl") }
        if modifiers & modOption != 0 { parts.append("Opt") }
        if modifiers & modShift != 0 { parts.append("Shift") }
        if modifiers & modCommand != 0 { parts.append("Cmd") }

        let keyName: String
        switch Int(keyCode) {
        case 123: keyName = "Left"
        case 124: keyName = "Right"
        case 126: keyName = "Up"
        case 125: keyName = "Down"
        case 36: keyName = "Return"
        case 48: keyName = "Tab"
        case 49: keyName = "Space"
        case 51: keyName = "Delete"
        case 53: keyName = "Esc"
        case 122: keyName = "F1"
        case 120: keyName = "F2"
        case 99: keyName = "F3"
        case 118: keyName = "F4"
        case 96: keyName = "F5"
        case 97: keyName = "F6"
        case 98: keyName = "F7"
        case 100: keyName = "F8"
        case 101: keyName = "F9"
        case 109: keyName = "F10"
        case 103: keyName = "F11"
        case 111: keyName = "F12"
        default:
            keyName = characterForKeyCode(keyCode)
        }

        parts.append(keyName)
        return parts.joined(separator: " + ")
    }

    private static func characterForKeyCode(_ keyCode: Int64) -> String {
        let source = CGEventSource(stateID: .hidSystemState)
        guard let event = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(keyCode), keyDown: true) else {
            return "Key(\(keyCode))"
        }
        var length = 0
        var chars = [UniChar](repeating: 0, count: 4)
        event.keyboardGetUnicodeString(maxStringLength: 4, actualStringLength: &length, unicodeString: &chars)
        if length > 0 {
            let str = String(utf16CodeUnits: chars, count: length).uppercased()
            if !str.isEmpty && str.first?.isWhitespace == false {
                return str
            }
        }
        return "Key(\(keyCode))"
    }

    // MARK: - Modifier Constants

    static let modCommand: UInt64  = 0x100000
    static let modControl: UInt64  = 0x40000
    static let modOption: UInt64   = 0x80000
    static let modShift: UInt64    = 0x20000
    static let modifierMask: UInt64 = 0x00FF0000

    // F3/F4 미디어 키코드 (kVK_F3=99, kVK_F4=101과 다름)
    static let keyMissionControl: Int64 = 160
    static let keyLaunchpad: Int64 = 131

    // MARK: - Presets

    private static let cmd = modCommand
    private static let ctrl = modControl

    static var defaultRules: [BlockRule] {[
        BlockRule(keyCode: Int64(kVK_ANSI_Q),     modifierFlags: cmd,  displayName: "Cmd + Q",         label: L.ruleQuit),
        BlockRule(keyCode: Int64(kVK_Tab),         modifierFlags: cmd,  displayName: "Cmd + Tab",       label: L.ruleAppSwitch),
        BlockRule(keyCode: Int64(kVK_ANSI_H),      modifierFlags: cmd,  displayName: "Cmd + H",         label: L.ruleHide),
        BlockRule(keyCode: Int64(kVK_ANSI_M),      modifierFlags: cmd,  displayName: "Cmd + M",         label: L.ruleMinimize),
        BlockRule(keyCode: Int64(kVK_Space),        modifierFlags: cmd,  displayName: "Cmd + Space",     label: L.ruleSpotlight),
        BlockRule(keyCode: Int64(kVK_LeftArrow),    modifierFlags: ctrl, displayName: "Ctrl + Left",     label: L.ruleSpaces),
        BlockRule(keyCode: Int64(kVK_RightArrow),   modifierFlags: ctrl, displayName: "Ctrl + Right",    label: L.ruleSpaces),
        BlockRule(keyCode: Int64(kVK_UpArrow),      modifierFlags: ctrl, displayName: "Ctrl + Up",       label: L.ruleSpaces),
        BlockRule(keyCode: Int64(kVK_DownArrow),    modifierFlags: ctrl, displayName: "Ctrl + Down",     label: L.ruleSpaces),
        BlockRule(keyCode: keyMissionControl,           modifierFlags: 0,    displayName: "F3",              label: L.ruleMissionControl),
        BlockRule(keyCode: keyLaunchpad,               modifierFlags: 0,    displayName: "F4",              label: L.ruleLaunchpad),
    ]}
}
