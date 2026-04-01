import Cocoa
import IOKit.pwr_mgt

/// macOS 시스템 기능 제어 (DND, 잠자기, Hot Corners, 커서)
final class SystemManager {
    static let shared = SystemManager()

    private var sleepAssertionID: IOPMAssertionID = 0
    private var isSleepPrevented = false

    private static let hotCornerKeys = [
        "wvous-tl-corner", "wvous-tr-corner",
        "wvous-bl-corner", "wvous-br-corner"
    ]

    private let savedHotCornersKey = "GK.savedHotCorners"

    // MARK: - DND (Do Not Disturb)

    func enableDND() { setDND(true) }
    func disableDND() { setDND(false) }

    private func setDND(_ enabled: Bool) {
        let suffix = enabled ? "turnOnDoNotDisturb" : "turnOffDoNotDisturb"
        DistributedNotificationCenter.default()
            .post(name: .init("com.apple.notificationcenterui.\(suffix)"), object: nil)

        let defaults = UserDefaults(suiteName: "com.apple.notificationcenterui")
        defaults?.set(enabled, forKey: "doNotDisturb")
    }

    // MARK: - 화면 잠자기 방지

    func preventSleep() {
        guard !isSleepPrevented else { return }

        let reason = "GameKeys for Mac - Game Mode Active" as CFString
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &sleepAssertionID
        )

        if result == kIOReturnSuccess {
            isSleepPrevented = true
        }
    }

    func allowSleep() {
        guard isSleepPrevented else { return }
        IOPMAssertionRelease(sleepAssertionID)
        isSleepPrevented = false
    }

    // MARK: - Hot Corners

    func disableHotCorners() {
        let defaults = UserDefaults(suiteName: "com.apple.dock")

        // 현재 설정 저장 (UserDefaults에 persist, 크래시 시에도 복원 가능)
        var saved: [String: Int] = [:]
        for corner in Self.hotCornerKeys {
            saved[corner] = defaults?.integer(forKey: corner) ?? 0
        }
        UserDefaults.standard.set(saved, forKey: savedHotCornersKey)

        // 모든 코너 비활성
        for corner in Self.hotCornerKeys {
            defaults?.set(0, forKey: corner)
        }

        restartDock()
    }

    func restoreHotCorners() {
        guard let saved = UserDefaults.standard.dictionary(forKey: savedHotCornersKey) as? [String: Int] else { return }
        let defaults = UserDefaults(suiteName: "com.apple.dock")

        for (corner, value) in saved {
            defaults?.set(value, forKey: corner)
        }
        UserDefaults.standard.removeObject(forKey: savedHotCornersKey)

        restartDock()
    }

    private func restartDock() {
        let task = Process()
        task.launchPath = "/usr/bin/killall"
        task.arguments = ["Dock"]
        try? task.run()
    }

    // MARK: - 커서 흔들어서 찾기

    func disableCursorShake() {
        UserDefaults.standard.set(true, forKey: "CGDisableCursorLocationMagnification")
    }

    func enableCursorShake() {
        UserDefaults.standard.removeObject(forKey: "CGDisableCursorLocationMagnification")
    }

    // MARK: - 전체 적용/해제

    func applyGameMode(state: AppState) {
        if state.isDNDEnabled { enableDND() }
        if state.isSleepPreventionEnabled { preventSleep() }
        if state.isHotCornersDisabled { disableHotCorners() }
        if state.isCursorShakeDisabled { disableCursorShake() }
    }

    func revertGameMode(snapshot: GameModeManager.FeatureSnapshot?) {
        guard let s = snapshot else { return }
        if s.dnd { disableDND() }
        if s.sleep { allowSleep() }
        if s.hotCorners { restoreHotCorners() }
        if s.cursorShake { enableCursorShake() }
    }
}
