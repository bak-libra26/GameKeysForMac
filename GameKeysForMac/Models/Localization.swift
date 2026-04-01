import Foundation

enum AppLanguage: String, CaseIterable, Codable {
    case korean = "ko"
    case english = "en"

    var displayName: String {
        switch self {
        case .korean: return "한국어"
        case .english: return "English"
        }
    }
}

/// 앱 전체 문자열 로컬라이제이션
enum L {
    static var lang: AppLanguage = .korean

    // MARK: - 팝오버

    static var gameModeOn: String { lang == .korean ? "게임 모드 끄기" : "Turn Off Game Mode" }
    static var gameModeOff: String { lang == .korean ? "게임 모드 켜기" : "Turn On Game Mode" }
    static var hotkeyHint: String { "Ctrl + Opt + G" }
    static var keyBlock: String { lang == .korean ? "단축키 차단" : "Block Shortcuts" }
    static var dnd: String { lang == .korean ? "방해금지" : "Do Not Disturb" }
    static var sleepPrevention: String { lang == .korean ? "잠자기 방지" : "Prevent Sleep" }
    static var hotCorners: String { lang == .korean ? "핫 코너" : "Hot Corners" }
    static var cursorShake: String { lang == .korean ? "커서 확대" : "Cursor Shake" }
    static var fnBlock: String { lang == .korean ? "Fn키 차단" : "Block Fn Key" }
    static var settings: String { lang == .korean ? "설정..." : "Settings..." }
    static var about: String { lang == .korean ? "GameKeys 정보" : "About GameKeys" }
    static var quit: String { lang == .korean ? "종료" : "Quit" }

    // MARK: - 설정 윈도우 사이드바

    static var tabKeys: String { lang == .korean ? "차단키" : "Block Keys" }
    static var tabSystem: String { lang == .korean ? "시스템" : "System" }
    static var tabGeneral: String { lang == .korean ? "일반" : "General" }

    // MARK: - 차단키 탭

    static var keysTitle: String { lang == .korean ? "차단키" : "Block Keys" }
    static var keysDesc: String { lang == .korean ? "게임 중 방해되는 macOS 단축키와 특수키를 차단합니다" : "Block macOS shortcuts that interrupt gameplay" }
    static var systemShortcuts: String { lang == .korean ? "시스템 단축키" : "System Shortcuts" }
    static var addKey: String { lang == .korean ? "+ 단축키 추가" : "+ Add Shortcut" }
    static var specialKeys: String { lang == .korean ? "특수키" : "Special Keys" }
    static var fnEmojiBlock: String { lang == .korean ? "Fn 키 이모지 피커 차단" : "Block Fn Key Emoji Picker" }
    static var fnEmojiDesc: String { lang == .korean ? "Fn/Globe 키의 이모지 창 차단" : "Block emoji picker from Fn/Globe key" }

    // MARK: - 시스템 탭

    static var systemTitle: String { lang == .korean ? "시스템" : "System" }
    static var systemDesc: String { lang == .korean ? "게임 모드 활성 시 macOS 시스템 동작을 제어합니다" : "Control macOS system behavior when Game Mode is active" }
    static var sectionNotification: String { lang == .korean ? "알림" : "Notifications" }
    static var dndFull: String { lang == .korean ? "방해금지 모드 (DND)" : "Do Not Disturb (DND)" }
    static var dndDesc: String { lang == .korean ? "게임 모드 ON 시 자동 활성" : "Auto-enable when Game Mode is ON" }
    static var sectionDisplay: String { lang == .korean ? "화면" : "Display" }
    static var hotCornersDisable: String { lang == .korean ? "Hot Corners 비활성화" : "Disable Hot Corners" }
    static var hotCornersDesc: String { lang == .korean ? "마우스 모서리 동작 차단" : "Block mouse corner actions" }
    static var sleepPrevent: String { lang == .korean ? "화면 잠자기 방지" : "Prevent Display Sleep" }
    static var sleepDesc: String { lang == .korean ? "잠자기 타이머 중지" : "Stop sleep timer" }
    static var sectionCursor: String { lang == .korean ? "커서" : "Cursor" }
    static var cursorShakeDisable: String { lang == .korean ? "\"흔들어서 찾기\" 비활성화" : "Disable \"Shake to Locate\"" }
    static var cursorShakeDesc: String { lang == .korean ? "빠른 마우스 움직임에 커서 확대 방지" : "Prevent cursor enlargement on fast mouse movement" }

    // MARK: - 일반 탭

    static var generalTitle: String { lang == .korean ? "일반" : "General" }
    static var generalDesc: String { lang == .korean ? "앱 동작 및 접근성을 설정합니다" : "Configure app behavior and accessibility" }
    static var launchAtLogin: String { lang == .korean ? "로그인 시 자동 시작" : "Launch at Login" }
    static var globalHotkey: String { lang == .korean ? "글로벌 핫키" : "Global Hotkey" }
    static var language: String { lang == .korean ? "언어" : "Language" }
    static var sectionAccessibility: String { lang == .korean ? "접근성" : "Accessibility" }
    static var accessibilityPermission: String { lang == .korean ? "접근성 권한" : "Accessibility Permission" }
    static var accessibilityGranted: String { lang == .korean ? "허용됨" : "Granted" }
    static var accessibilityNeeded: String { lang == .korean ? "허용 필요" : "Required" }
    static var openSystemSettings: String { lang == .korean ? "시스템 설정 열기" : "Open System Settings" }

    // MARK: - 모달

    static var addKeyTitle: String { lang == .korean ? "새 단축키 등록" : "Add New Shortcut" }
    static var pressAnyKey: String { lang == .korean ? "아무 키를 누르세요" : "Press any key" }
    static var keyNamePlaceholder: String { lang == .korean ? "이름 (예: 앱 닫기 방지)" : "Name (e.g. Prevent App Quit)" }
    static var cancel: String { lang == .korean ? "취소" : "Cancel" }
    static var add: String { lang == .korean ? "추가" : "Add" }
    static var blockSuffix: String { lang == .korean ? " 차단" : " Block" }

    // MARK: - 기본 차단키 라벨

    static var ruleQuit: String { lang == .korean ? "앱 종료 방지" : "Prevent App Quit" }
    static var ruleAppSwitch: String { lang == .korean ? "앱 전환 방지" : "Prevent App Switch" }
    static var ruleHide: String { lang == .korean ? "앱 숨기기 방지" : "Prevent App Hide" }
    static var ruleMinimize: String { lang == .korean ? "최소화 방지" : "Prevent Minimize" }
    static var ruleSpotlight: String { lang == .korean ? "Spotlight 방지" : "Prevent Spotlight" }
    static var ruleSpaces: String { lang == .korean ? "Spaces 전환 방지" : "Prevent Spaces Switch" }
    static var ruleMissionControl: String { lang == .korean ? "Mission Control 방지" : "Prevent Mission Control" }
    static var ruleLaunchpad: String { lang == .korean ? "Launchpad 방지" : "Prevent Launchpad" }

    private static var ko: Bool { lang == .korean }
}
