# GameKeys for Mac

macOS에서 게임할 때 방해되는 시스템 동작을 차단하는 메뉴바 앱.

macOS의 Game Mode가 해결하지 못하는 문제들을 해결합니다.

## 기능

### 시스템 단축키 차단
- `Cmd + Q` — 실수로 게임 종료 방지
- `Cmd + Tab` — 앱 전환 방지
- `Cmd + H` — 앱 숨기기 방지
- `Cmd + M` — 최소화 방지
- `Cmd + Space` — Spotlight 방지
- `Ctrl + 방향키` — Spaces 전환 방지
- `F3` — Mission Control 방지
- `F4` — Launchpad 방지
- 커스텀 단축키 추가 가능

### 시스템 제어
- **방해금지 모드 (DND)** — 게임 중 알림 차단
- **Hot Corners 비활성화** — 마우스 모서리 동작 차단
- **화면 잠자기 방지** — 잠자기 타이머 중지
- **커서 흔들어서 찾기 비활성화** — 빠른 마우스 움직임에 커서 확대 방지
- **Fn 키 이모지 피커 차단**

### 사용법
1. 메뉴바의 방패 아이콘 클릭
2. **게임 모드 켜기** 선택
3. 끝. 모든 차단이 한번에 적용됩니다.

글로벌 핫키 `Ctrl + Opt + G`로 어디서든 토글 가능.

## 스크린샷

### 팝오버
게임 모드 ON/OFF + 각 기능 개별 토글

### 설정
차단키 관리 / 시스템 옵션 / 일반 설정 (언어 포함)

## 요구 사항

- macOS 14.0+
- 접근성 권한 필요 (시스템 설정 > 개인정보 보호 및 보안 > 접근성)

## 빌드

```bash
git clone https://github.com/simjunghun/GameKeysForMac.git
cd GameKeysForMac
xcodebuild -scheme GameKeysForMac -configuration Release build
```

또는 Xcode에서 `GameKeysForMac.xcodeproj`를 열고 빌드.

## 왜 만들었나?

macOS Sonoma에 Game Mode가 추가됐지만:
- 시스템 단축키를 차단하지 않음
- Hot Corners를 비활성화하지 않음
- Dock/메뉴바 자동 표시를 막지 않음
- 설정/커스터마이징 없음

메이플스토리, League of Legends, CS2 등 맥에서 게임하는 유저들이 실제로 겪는 불편함을 해결하기 위해 만들었습니다.

## 라이선스

MIT License
