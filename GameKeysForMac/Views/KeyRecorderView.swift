import SwiftUI
import Carbon.HIToolbox

struct KeyRecorderView: View {
    @Binding var isRecording: Bool
    var onKeyRecorded: (Int64, UInt64, String) -> Void  // keyCode, modifiers, displayName

    @State private var recordedKeyName: String = "키를 누르세요..."
    @State private var currentMonitor: Any?

    var body: some View {
        VStack(spacing: 8) {
            Text(recordedKeyName)
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(isRecording ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isRecording ? Color.blue : Color.gray, lineWidth: 1)
                )

            if isRecording {
                Text("아무 키나 누르면 등록됩니다")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            if isRecording {
                startRecording()
            }
        }
        .onChange(of: isRecording) { _, newValue in
            if newValue {
                startRecording()
            } else {
                stopRecording()
            }
        }
        .onDisappear {
            stopRecording()
        }
    }

    private func startRecording() {
        stopRecording()

        currentMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let keyCode = Int64(event.keyCode)
            let modifiers = UInt64(event.modifierFlags.rawValue & 0x00FF0000)
            let displayName = Self.displayName(keyCode: keyCode, modifiers: modifiers)

            recordedKeyName = displayName
            onKeyRecorded(keyCode, modifiers, displayName)
            isRecording = false

            return nil // consume the event
        }
    }

    private func stopRecording() {
        if let monitor = currentMonitor {
            NSEvent.removeMonitor(monitor)
            currentMonitor = nil
        }
    }

    // MARK: - Key Name Formatting

    static func displayName(keyCode: Int64, modifiers: UInt64) -> String {
        var parts: [String] = []

        if modifiers & 0x40000 != 0 { parts.append("Ctrl") }
        if modifiers & 0x80000 != 0 { parts.append("Opt") }
        if modifiers & 0x20000 != 0 { parts.append("Shift") }
        if modifiers & 0x100000 != 0 { parts.append("Cmd") }

        let keyName: String
        switch Int(keyCode) {
        case kVK_LeftArrow: keyName = "Left"
        case kVK_RightArrow: keyName = "Right"
        case kVK_UpArrow: keyName = "Up"
        case kVK_DownArrow: keyName = "Down"
        case kVK_Return: keyName = "Return"
        case kVK_Tab: keyName = "Tab"
        case kVK_Space: keyName = "Space"
        case kVK_Delete: keyName = "Delete"
        case kVK_Escape: keyName = "Esc"
        case kVK_F1: keyName = "F1"
        case kVK_F2: keyName = "F2"
        case kVK_F3: keyName = "F3"
        case kVK_F4: keyName = "F4"
        case kVK_F5: keyName = "F5"
        case kVK_F6: keyName = "F6"
        case kVK_F7: keyName = "F7"
        case kVK_F8: keyName = "F8"
        case kVK_F9: keyName = "F9"
        case kVK_F10: keyName = "F10"
        case kVK_F11: keyName = "F11"
        case kVK_F12: keyName = "F12"
        default:
            // CGEvent를 사용해서 실제 키 문자를 가져옴
            keyName = Self.characterForKeyCode(keyCode)
        }

        parts.append(keyName)
        return parts.joined(separator: " + ")
    }

    /// keyCode → 실제 키보드 문자 변환 (CGEvent 기반)
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
}
