import SwiftUI
import ServiceManagement
import Carbon.HIToolbox

// MARK: - Design Tokens

private enum DS {
    static let accent = Color(nsColor: NSColor(red: 0.19, green: 0.82, blue: 0.35, alpha: 1))

    // Typography
    static let titleFont    = Font.system(size: 15, weight: .semibold)
    static let bodyFont     = Font.system(size: 13)
    static let captionFont  = Font.system(size: 11)
    static let monoFont     = Font.system(size: 11, weight: .medium, design: .monospaced)
    static let sectionFont  = Font.system(size: 11, weight: .medium)
    static let microFont    = Font.system(size: 10)

    // Spacing
    static let cardPadH: CGFloat = 14
    static let cardPadV: CGFloat = 9
    static let cardRadius: CGFloat = 8
    static let sidebarWidth: CGFloat = 150
    static let contentPad: CGFloat = 24

    // Sidebar
    static let sidebarIconSize: CGFloat = 14
    static let sidebarItemFont = Font.system(size: 13)
}

// MARK: - Settings Window

struct SettingsView: View {
    @ObservedObject var appState: AppState
    @ObservedObject var gameMode: GameModeManager
    @State private var selectedTab: SettingsTab = .keys

    enum SettingsTab: CaseIterable {
        case keys, system, general

        var icon: String {
            switch self {
            case .keys: return "keyboard"
            case .system: return "shield"
            case .general: return "gearshape"
            }
        }

        var title: String {
            switch self {
            case .keys: return L.tabKeys
            case .system: return L.tabSystem
            case .general: return L.tabGeneral
            }
        }
    }

    var body: some View {
        HSplitView {
            // Sidebar
            VStack(alignment: .leading, spacing: 2) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    SidebarItem(title: tab.title, icon: tab.icon, isSelected: selectedTab == tab) {
                        selectedTab = tab
                    }
                    if tab == .system {
                        Divider().padding(.vertical, 6).padding(.horizontal, 8)
                    }
                }
                Spacer()
                Text("GameKeys for Mac v1.0.0")
                    .font(DS.microFont)
                    .foregroundColor(.secondary.opacity(0.4))
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
            }
            .padding(8)
            .frame(width: DS.sidebarWidth)

            // Content
            VStack(alignment: .leading, spacing: 0) {
                switch selectedTab {
                case .keys: KeysTab(appState: appState)
                case .system: SystemTab(appState: appState)
                case .general: GeneralTab(appState: appState, gameMode: gameMode)
                }
                Spacer()
            }
            .padding(DS.contentPad)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(minWidth: 580, minHeight: 420)
    }
}

// MARK: - Sidebar Item

private struct SidebarItem: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: DS.sidebarIconSize))
                    .frame(width: 18)
                Text(title)
                    .font(DS.sidebarItemFont)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(isSelected ? DS.accent.opacity(0.15) : Color.clear)
            .foregroundColor(isSelected ? DS.accent : .secondary)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 차단키 탭

private struct KeysTab: View {
    @ObservedObject var appState: AppState
    @State private var showAddKey = false

    var body: some View {
        PageHeader(title: L.keysTitle, desc: L.keysDesc)

        SectionLabel(L.systemShortcuts)

        CardGroup {
            ForEach(Array(appState.blockRules.enumerated()), id: \.element.id) { index, rule in
                if index > 0 { CardDivider() }
                KeyRow(
                    key: rule.displayName,
                    label: localizedLabel(for: rule),
                    isOn: $appState.blockRules[index].isEnabled,
                    onDelete: {
                        appState.blockRules.remove(at: index)
                    }
                )
            }
        }

        DashedButton(L.addKey) { showAddKey = true }
            .padding(.top, 6)
            .sheet(isPresented: $showAddKey) {
                AddKeyModal { code, mods, display, desc in
                    let rule = BlockRule(keyCode: code, modifierFlags: mods, displayName: display, label: desc)
                    if !appState.blockRules.contains(where: { $0.keyCode == code && $0.modifierFlags == mods }) {
                        appState.blockRules.append(rule)
                    }
                }
            }

        SectionLabel(L.specialKeys)

        CardGroup {
            ToggleRow(title: L.fnEmojiBlock, subtitle: L.fnEmojiDesc, isOn: $appState.isFnBlockEnabled)
        }
    }

    /// keyCode+modifiers → 로컬라이즈된 라벨 딕셔너리 (렌더마다 재생성 방지)
    private var localizedLabels: [String: String] {
        Dictionary(
            uniqueKeysWithValues: BlockRule.defaultRules.map {
                ("\($0.keyCode)-\($0.modifierFlags)", $0.label)
            }
        )
    }

    private func localizedLabel(for rule: BlockRule) -> String {
        localizedLabels["\(rule.keyCode)-\(rule.modifierFlags)"] ?? rule.label
    }
}

// MARK: - 시스템 탭

private struct SystemTab: View {
    @ObservedObject var appState: AppState

    var body: some View {
        PageHeader(title: L.systemTitle, desc: L.systemDesc)

        SectionLabel(L.sectionNotification)
        CardGroup {
            ToggleRow(title: L.dndFull, subtitle: L.dndDesc, isOn: $appState.isDNDEnabled)
        }

        SectionLabel(L.sectionDisplay)
        CardGroup {
            ToggleRow(title: L.hotCornersDisable, subtitle: L.hotCornersDesc, isOn: $appState.isHotCornersDisabled)
            CardDivider()
            ToggleRow(title: L.sleepPrevent, subtitle: L.sleepDesc, isOn: $appState.isSleepPreventionEnabled)
        }

        SectionLabel(L.sectionCursor)
        CardGroup {
            ToggleRow(title: L.cursorShakeDisable, subtitle: L.cursorShakeDesc, isOn: $appState.isCursorShakeDisabled)
        }
    }
}

// MARK: - 일반 탭

private struct GeneralTab: View {
    @ObservedObject var appState: AppState
    @ObservedObject var gameMode: GameModeManager

    var body: some View {
        PageHeader(title: L.generalTitle, desc: L.generalDesc)

        CardGroup {
            ToggleRow(title: L.launchAtLogin, isOn: $appState.launchAtLogin)
                .onChange(of: appState.launchAtLogin) { _, v in toggleLogin(v) }
            CardDivider()
            InfoRow(label: L.globalHotkey) {
                KeyBadge("Ctrl + Opt + G")
            }
            CardDivider()
            InfoRow(label: L.language) {
                Picker("", selection: $appState.language) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .frame(width: 80)
            }
        }

        SectionLabel(L.sectionAccessibility)
        CardGroup {
            InfoRow(label: L.accessibilityPermission) {
                if gameMode.isAccessibilityGranted {
                    Label(L.accessibilityGranted, systemImage: "checkmark.circle.fill")
                        .font(DS.captionFont)
                        .foregroundColor(DS.accent)
                } else {
                    Label(L.accessibilityNeeded, systemImage: "exclamationmark.triangle.fill")
                        .font(DS.captionFont)
                        .foregroundColor(.orange)
                }
            }
            CardDivider()
            HStack {
                Spacer()
                Button(L.openSystemSettings) {
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                }
                .font(DS.captionFont)
                .foregroundColor(DS.accent)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, DS.cardPadH)
            .padding(.vertical, DS.cardPadV)
        }
    }

    private func toggleLogin(_ on: Bool) {
        if #available(macOS 13.0, *) {
            try? on ? SMAppService.mainApp.register() : SMAppService.mainApp.unregister()
        }
    }
}


// MARK: - Reusable Components

private struct PageHeader: View {
    let title: String; let desc: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(DS.titleFont)
            Text(desc).font(DS.captionFont).foregroundColor(.secondary)
        }.padding(.bottom, 16)
    }
}

private struct SectionLabel: View {
    let t: String
    init(_ t: String) { self.t = t }
    var body: some View {
        Text(t).font(DS.sectionFont).foregroundColor(.secondary)
            .padding(.top, 16).padding(.bottom, 6)
    }
}

private struct CardGroup<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        VStack(spacing: 0) { content }
            .background(.quaternary.opacity(0.5))
            .cornerRadius(DS.cardRadius)
            .overlay(RoundedRectangle(cornerRadius: DS.cardRadius).stroke(.quaternary, lineWidth: 0.5))
    }
}

private struct CardDivider: View {
    var body: some View { Divider().padding(.leading, DS.cardPadH) }
}

private struct KeyRow: View {
    let key: String; let label: String
    @Binding var isOn: Bool
    var onDelete: (() -> Void)? = nil
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            Text(key)
                .font(DS.monoFont)
                .foregroundColor(DS.accent)
                .frame(minWidth: 100, alignment: .leading)
            Text(label)
                .font(DS.captionFont)
                .foregroundColor(.secondary)
            Spacer()
            if isHovered, let onDelete = onDelete {
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                        .foregroundColor(.red.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch).labelsHidden().controlSize(.mini)
                .tint(DS.accent)
        }
        .padding(.horizontal, DS.cardPadH)
        .padding(.vertical, 7)
        .onHover { isHovered = $0 }
    }
}

private struct ToggleRow: View {
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(DS.bodyFont)
                if let s = subtitle { Text(s).font(DS.microFont).foregroundColor(.secondary) }
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch).labelsHidden().controlSize(.mini)
                .tint(DS.accent)
        }
        .padding(.horizontal, DS.cardPadH)
        .padding(.vertical, DS.cardPadV)
    }
}

private struct InfoRow<Trailing: View>: View {
    let label: String
    @ViewBuilder let trailing: Trailing
    var body: some View {
        HStack {
            Text(label).font(DS.bodyFont)
            Spacer()
            trailing
        }
        .padding(.horizontal, DS.cardPadH)
        .padding(.vertical, DS.cardPadV)
    }
}

private struct KeyBadge: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(DS.monoFont)
            .foregroundColor(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.quaternary)
            .cornerRadius(5)
    }
}

private struct DashedButton: View {
    let title: String; let action: () -> Void
    init(_ title: String, action: @escaping () -> Void) { self.title = title; self.action = action }
    var body: some View {
        Button(action: action) {
            Text(title).font(DS.captionFont).foregroundColor(.secondary)
                .frame(maxWidth: .infinity).padding(.vertical, 8)
                .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4])).foregroundColor(.secondary.opacity(0.25)))
        }.buttonStyle(.plain)
    }
}

// MARK: - Add Key Modal

struct AddKeyModal: View {
    @Environment(\.dismiss) private var dismiss
    @State private var capturedKey = ""
    @State private var code: Int64 = 0
    @State private var mods: UInt64 = 0
    @State private var name = ""
    @State private var monitor: Any?
    var onAdd: (Int64, UInt64, String, String) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(L.addKeyTitle).font(.system(size: 14, weight: .semibold))

            Text(capturedKey.isEmpty ? L.pressAnyKey : capturedKey)
                .font(capturedKey.isEmpty ? DS.bodyFont : .system(size: 22, weight: .semibold, design: .monospaced))
                .foregroundColor(capturedKey.isEmpty ? .secondary : .primary)
                .frame(maxWidth: .infinity).padding(.vertical, 22)
                .background(.quaternary)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(capturedKey.isEmpty ? Color.secondary.opacity(0.3) : DS.accent, lineWidth: 1.5))
                .cornerRadius(8)

            TextField(L.keyNamePlaceholder, text: $name)
                .textFieldStyle(.roundedBorder).font(DS.bodyFont)

            HStack {
                Button(L.cancel) { stop(); dismiss() }.keyboardShortcut(.cancelAction)
                Spacer()
                Button(L.add) { onAdd(code, mods, capturedKey, name); stop(); dismiss() }
                    .keyboardShortcut(.defaultAction).disabled(capturedKey.isEmpty)
                    .buttonStyle(.borderedProminent).tint(DS.accent)
            }
        }
        .padding(22).frame(width: 320)
        .onAppear { start() }.onDisappear { stop() }
    }

    private func start() {
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { e in
            code = Int64(e.keyCode)
            mods = UInt64(e.modifierFlags.rawValue & 0x00FF0000)
            capturedKey = KeyRecorderView.displayName(keyCode: code, modifiers: mods)
            if name.isEmpty { name = capturedKey + L.blockSuffix }
            return nil
        }
    }
    private func stop() { if let m = monitor { NSEvent.removeMonitor(m); monitor = nil } }
}
