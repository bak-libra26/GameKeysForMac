import Cocoa
import IOKit.pwr_mgt

/// macOS 시스템 기능 제어 (DND, 잠자기, Hot Corners, 커서)
final class SystemManager {
    static let shared = SystemManager()

    private var sleepAssertionID: IOPMAssertionID = 0
    private var isSleepPrevented = false
    private var savedHotCorners: [String: Int]?

    // MARK: - DND (Do Not Disturb)

    func enableDND() {
        // macOS Monterey+: Focus/DND via defaults
        let center = DistributedNotificationCenter.default()
        center.post(name: .init("com.apple.notificationcenterui.turnOnDoNotDisturb"), object: nil)

        // 백업: defaults로 직접 설정
        let defaults = UserDefaults(suiteName: "com.apple.notificationcenterui")
        defaults?.set(true, forKey: "doNotDisturb")
        defaults?.synchronize()
    }

    func disableDND() {
        let center = DistributedNotificationCenter.default()
        center.post(name: .init("com.apple.notificationcenterui.turnOffDoNotDisturb"), object: nil)

        let defaults = UserDefaults(suiteName: "com.apple.notificationcenterui")
        defaults?.set(false, forKey: "doNotDisturb")
        defaults?.synchronize()
    }

    // MARK: - 화면 잠자기 방지

    func preventSleep() {
        guard !isSleepPrevented else { return }

        let reason = "GameKeys for Mac - 게임 모드 활성" as CFString
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

        // 현재 설정 저장
        savedHotCorners = [:]
        for corner in ["wvous-tl-corner", "wvous-tr-corner", "wvous-bl-corner", "wvous-br-corner"] {
            savedHotCorners?[corner] = defaults?.integer(forKey: corner) ?? 0
        }

        // 모든 코너를 비활성 (0 = no action)
        for corner in ["wvous-tl-corner", "wvous-tr-corner", "wvous-bl-corner", "wvous-br-corner"] {
            defaults?.set(0, forKey: corner)
        }
        defaults?.synchronize()

        // Dock 재시작하여 적용
        restartDock()
    }

    func restoreHotCorners() {
        guard let saved = savedHotCorners else { return }
        let defaults = UserDefaults(suiteName: "com.apple.dock")

        for (corner, value) in saved {
            defaults?.set(value, forKey: corner)
        }
        defaults?.synchronize()
        savedHotCorners = nil

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
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "CGDisableCursorLocationMagnification")
    }

    func enableCursorShake() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "CGDisableCursorLocationMagnification")
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
