import Cocoa
import Carbon.HIToolbox

/// CGEvent Tap 기반 키 차단 + 글로벌 핫키 + 게임 모드 총괄
final class GameModeManager: ObservableObject {
    let appState: AppState
    @Published var isAccessibilityGranted = false

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var tapCheckTimer: Timer?
    private var retainedSelf: Unmanaged<GameModeManager>?
    private var hotkeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?

    private var cachedRules: [BlockRule] = []
    private var activeSnapshot: FeatureSnapshot?

    /// 게임 모드 활성화 시점의 설정 스냅샷 (해제 시 정확한 복원용)
    struct FeatureSnapshot {
        let dnd: Bool
        let sleep: Bool
        let hotCorners: Bool
        let cursorShake: Bool

        init(state: AppState) {
            self.dnd = state.isDNDEnabled
            self.sleep = state.isSleepPreventionEnabled
            self.hotCorners = state.isHotCornersDisabled
            self.cursorShake = state.isCursorShakeDisabled
        }
    }

    init(appState: AppState) {
        self.appState = appState
        updateCachedRules()
        refreshAccessibility()
    }

    // MARK: - Game Mode Toggle

    func toggleGameMode() {
        if appState.isGameModeEnabled {
            deactivateGameMode()
        } else {
            activateGameMode()
        }
    }

    func activateGameMode() {
        appState.isGameModeEnabled = true
        updateCachedRules()
        activeSnapshot = FeatureSnapshot(state: appState)

        if appState.isKeyBlockEnabled {
            startIntercepting()
        }
        SystemManager.shared.applyGameMode(state: appState)
    }

    func deactivateGameMode() {
        appState.isGameModeEnabled = false
        stopIntercepting()
        SystemManager.shared.revertGameMode(snapshot: activeSnapshot)
        activeSnapshot = nil
    }

    // MARK: - Rules Cache

    func updateCachedRules() {
        cachedRules = appState.blockRules.filter(\.isEnabled)
    }

    // MARK: - Event Tap

    private func startIntercepting() {
        guard eventTap == nil else { return }

        let retained = Unmanaged.passRetained(self)
        retainedSelf = retained

        // keyDown만 감시 (keyUp은 항상 게임에 전달되어야 하므로 tap 불필요)
        let eventMask: CGEventMask = 1 << CGEventType.keyDown.rawValue

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { _, type, event, refcon -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passUnretained(event) }

                if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                    let manager = Unmanaged<GameModeManager>.fromOpaque(refcon).takeUnretainedValue()
                    DispatchQueue.main.async { manager.reEnableTap() }
                    return Unmanaged.passUnretained(event)
                }

                let manager = Unmanaged<GameModeManager>.fromOpaque(refcon).takeUnretainedValue()
                return manager.handleEvent(event)
            },
            userInfo: retained.toOpaque()
        ) else {
            retained.release()
            retainedSelf = nil
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
            AXIsProcessTrustedWithOptions(options)
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        tapCheckTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkTapHealth()
        }
    }

    private func stopIntercepting() {
        tapCheckTimer?.invalidate()
        tapCheckTimer = nil

        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
        retainedSelf?.release()
        retainedSelf = nil
    }

    // MARK: - Event Handling

    private func handleEvent(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags.rawValue

        let rules = cachedRules

        for rule in rules {
            if rule.matches(keyCode: keyCode, flags: flags) {
                return nil
            }
        }

        return Unmanaged.passUnretained(event)
    }

    // MARK: - Tap Recovery

    private func reEnableTap() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
    }

    private func checkTapHealth() {
        guard appState.isGameModeEnabled, appState.isKeyBlockEnabled else { return }
        if let tap = eventTap {
            if !CGEvent.tapIsEnabled(tap: tap) {
                CGEvent.tapEnable(tap: tap, enable: true)
            }
        } else {
            startIntercepting()
        }
    }

    // MARK: - Global Hotkey (Ctrl+Option+G)

    func registerGlobalHotkey() {
        guard hotkeyRef == nil else { return }

        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x474B4559)
        hotKeyID.id = 1

        let status = RegisterEventHotKey(
            UInt32(kVK_ANSI_G),
            UInt32(controlKey | optionKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotkeyRef
        )

        if status == noErr {
            installHotkeyHandler()
        }
    }

    private func installHotkeyHandler() {
        guard eventHandlerRef == nil else { return }

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, userData -> OSStatus in
                guard let userData = userData else { return OSStatus(eventNotHandledErr) }
                let manager = Unmanaged<GameModeManager>.fromOpaque(userData).takeUnretainedValue()
                DispatchQueue.main.async { manager.toggleGameMode() }
                return noErr
            },
            1,
            &eventType,
            selfPtr,
            &eventHandlerRef
        )
    }

    // MARK: - Accessibility

    func refreshAccessibility() {
        isAccessibilityGranted = AXIsProcessTrusted()
    }

    deinit {
        stopIntercepting()
        if let ref = hotkeyRef {
            UnregisterEventHotKey(ref)
        }
        if let ref = eventHandlerRef {
            RemoveEventHandler(ref)
        }
    }
}
