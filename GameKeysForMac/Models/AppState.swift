import Foundation

/// 앱 전체 상태를 관리하는 중앙 저장소
/// UserDefaults에 자동 저장/복원
final class AppState: ObservableObject {

    // MARK: - 게임 모드 마스터 토글

    @Published var isGameModeEnabled = false

    // MARK: - 기능별 토글

    @Published var isKeyBlockEnabled: Bool {
        didSet { save("keyBlock", isKeyBlockEnabled) }
    }
    @Published var isSleepPreventionEnabled: Bool {
        didSet { save("sleepPrevention", isSleepPreventionEnabled) }
    }
    @Published var isCursorShakeDisabled: Bool {
        didSet { save("cursorShake", isCursorShakeDisabled) }
    }

    // MARK: - 차단키 목록

    @Published var blockRules: [BlockRule] {
        didSet { saveRules() }
    }

    // MARK: - 일반 설정

    @Published var launchAtLogin: Bool {
        didSet { save("launchAtLogin", launchAtLogin) }
    }

    @Published var language: AppLanguage {
        didSet {
            defaults.set(language.rawValue, forKey: prefix + "language")
            L.lang = language
        }
    }

    // MARK: - Init

    private let defaults = UserDefaults.standard
    private let prefix = "GK."

    init() {
        self.isKeyBlockEnabled = defaults.object(forKey: "GK.keyBlock") as? Bool ?? true
        self.isSleepPreventionEnabled = defaults.object(forKey: "GK.sleepPrevention") as? Bool ?? true
        self.isCursorShakeDisabled = defaults.object(forKey: "GK.cursorShake") as? Bool ?? false
        self.launchAtLogin = defaults.object(forKey: "GK.launchAtLogin") as? Bool ?? false

        if let langStr = defaults.string(forKey: "GK.language"),
           let lang = AppLanguage(rawValue: langStr) {
            self.language = lang
        } else {
            let sysLang = Locale.current.language.languageCode?.identifier ?? "en"
            self.language = sysLang == "ko" ? .korean : .english
        }

        if let data = defaults.data(forKey: "GK.blockRules"),
           let rules = try? JSONDecoder().decode([BlockRule].self, from: data) {
            self.blockRules = rules
        } else {
            self.blockRules = BlockRule.defaultRules
        }

        L.lang = self.language
    }

    // MARK: - Persistence

    private func save(_ key: String, _ value: Bool) {
        defaults.set(value, forKey: prefix + key)
    }

    private func saveRules() {
        if let data = try? JSONEncoder().encode(blockRules) {
            defaults.set(data, forKey: prefix + "blockRules")
        }
    }
}
