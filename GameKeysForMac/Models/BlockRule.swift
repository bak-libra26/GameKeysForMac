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

    // MARK: - Presets

    private static let cmd: UInt64 = 0x100000   // NSEvent.ModifierFlags.command
    private static let ctrl: UInt64 = 0x40000   // NSEvent.ModifierFlags.control

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
        BlockRule(keyCode: 160,                       modifierFlags: 0,    displayName: "F3",              label: L.ruleMissionControl),  // Mission Control (kVK_F3=99와 다름)
        BlockRule(keyCode: 131,                       modifierFlags: 0,    displayName: "F4",              label: L.ruleLaunchpad),         // Launchpad (kVK_F4=101과 다름)
    ]}
}
