import SwiftUI

struct KeyRecorderView: View {
    @Binding var isRecording: Bool
    var onKeyRecorded: (Int64, UInt64, String) -> Void

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
            if isRecording { startRecording() }
        }
        .onChange(of: isRecording) { _, newValue in
            if newValue { startRecording() } else { stopRecording() }
        }
        .onDisappear { stopRecording() }
    }

    private func startRecording() {
        stopRecording()
        currentMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let keyCode = Int64(event.keyCode)
            let modifiers = UInt64(event.modifierFlags.rawValue) & BlockRule.modifierMask
            let name = BlockRule.formatKeyName(keyCode: keyCode, modifiers: modifiers)
            recordedKeyName = name
            onKeyRecorded(keyCode, modifiers, name)
            isRecording = false
            return nil
        }
    }

    private func stopRecording() {
        if let monitor = currentMonitor {
            NSEvent.removeMonitor(monitor)
            currentMonitor = nil
        }
    }
}
