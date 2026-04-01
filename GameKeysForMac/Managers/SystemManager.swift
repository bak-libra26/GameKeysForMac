import Cocoa
import IOKit.pwr_mgt

/// macOS 시스템 기능 제어 (잠자기, 커서)
final class SystemManager {
    static let shared = SystemManager()

    private var sleepAssertionID: IOPMAssertionID = 0
    private var isSleepPrevented = false

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

    // MARK: - 커서 흔들어서 찾기

    func disableCursorShake() {
        UserDefaults.standard.set(true, forKey: "CGDisableCursorLocationMagnification")
    }

    func enableCursorShake() {
        UserDefaults.standard.removeObject(forKey: "CGDisableCursorLocationMagnification")
    }

    // MARK: - 전체 적용/해제

    func applyGameMode(state: AppState) {
        if state.isSleepPreventionEnabled { preventSleep() }
        if state.isCursorShakeDisabled { disableCursorShake() }
    }

    func revertGameMode(snapshot: GameModeManager.FeatureSnapshot?) {
        guard let s = snapshot else { return }
        if s.sleep { allowSleep() }
        if s.cursorShake { enableCursorShake() }
    }
}
