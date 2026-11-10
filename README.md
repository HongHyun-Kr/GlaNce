<p align="center">
  <b>GlaNce</b><br>
  A tiny mirror camera that lives in your macOS menu bar.<br>
  메뉴바에서 한 번에 여는 macOS 거울 카메라
</p>

---

## Overview

GlaNce는 메뉴바 아이콘을 누르면 말풍선 팝업으로 거울 카메라가 열리는 macOS 앱이다.
얼굴을 잠깐 확인하고, 날짜·시간·위치가 들어간 사진을 찍어 바로 붙여넣을 수 있다.

Click the menu bar icon to open a mirrored camera in a popover. Check yourself, snap a 
photo stamped with date, time and city, and paste it anywhere with ⌘V.

## Features

**Camera**
- 메뉴바 팝업으로 바로 열리는 거울(좌우반전) 카메라
- 사진 비율 16:9 / 4:3 / 3:2 / 1:1, 미리보기와 저장 사진이 같은 비율로 크롭
- 팝업을 잡고 끌어내리면 항상 위에 떠 있는 창으로 분리
- 우하단 모서리 드래그로 창 크기 조절 (1~10단계)
- 팝업이나 설정 창이 닫히면 카메라 자동 종료

**Shooting**
- 스페이스바 / 엔터 / 셔터 버튼으로 촬영, 촬영 플래시 애니메이션
- 타이머 (끔 → 3초 → 5초), 카운트다운 중 다시 누르면 취소
- 찍자마자 클립보드에 복사돼서 ⌘V로 바로 붙여넣기

**Stamp & caption**
- 날짜 · 시간 · 도시 이름 워터마크, 촬영할 때마다 현재 위치 반영
- 시간 표기 24시간 / 12시간 / 초까지, 날짜 표기 3종
- 글꼴 7종 (AppleGothic, AppleMyungjo 포함), 흰색 / 검정 / 레트로 주황 필름 스타일
- 사진 틀 모양 피커로 7곳 중 자리 선택, 크기 · 진하기 · 글자 간격 조절
- 사진 위쪽 가운데에 한 줄 문구 (좌상단 버튼 또는 더블클릭으로 입력)
- 카메라 화면에 워터마크가 실시간으로 표시돼서 찍히는 모습 그대로 확인

**Settings**
- 왼쪽 탭 구성: 일반 · 날짜·위치 표시 · 상단 문구 · 저장 · 접근 권한 · 메뉴바 아이콘
- 설정 미리보기에 카메라 실시간 화면 반영
- 한국어 / English 전환
- 메뉴바 아이콘 10종

## Requirements

- macOS 13 Ventura or later
- Apple Silicon / Intel (Universal binary)

## Install

### Download

1. [Releases](../../releases)에서 `GlaNce.zip`을 받아 압축을 푼다.
2. `GlaNce.app`을 **응용 프로그램** 폴더로 옮긴다.
3. 처음 실행하면 "확인되지 않은 개발자" 경고가 뜬다.
   시스템 설정 → 개인정보 보호 및 보안 → 하단의 **그래도 열기**를 누른다.

Apple 공증을 받지 않은 개인 프로젝트라 처음 한 번만 필요한 과정이다.
처음 실행하면 카메라와 위치 권한을 묻는다. 위치를 거부하면 날짜·시간만 찍힌다.

### Build from source

Xcode 없이 Command Line Tools만 있으면 된다.

```bash
xcode-select --install        # 처음 한 번만
git clone https://github.com/HongHyun-kr/GlaNce.git
cd GlaNce
bash build.sh                 # /Applications/GlaNce.app 설치
open /Applications/GlaNce.app
```

`bash build.sh --zip`을 쓰면 배포용 `GlaNce.zip`도 같이 만든다.

## Usage

| 동작 | 방법 |
|---|---|
| 카메라 열기 / 닫기 | 메뉴바 아이콘 클릭 |
| 촬영 | 스페이스바, 엔터, 또는 우하단 셔터 |
| 타이머 | 셔터 위 타이머 버튼 (끔 → 3초 → 5초) |
| 상단 문구 | 좌상단 버튼 또는 위쪽 가운데 더블클릭 → 입력 후 엔터 |
| 창 크기 | 우하단 모서리 드래그 |
| 떠 있는 창으로 분리 | 카메라 화면을 잡고 아래로 드래그 |
| 저장 폴더 열기 | 셔터 옆 폴더 버튼 |
| 설정 | 우상단 톱니바퀴 |
| 종료 | 우상단 전원 버튼 |

사진은 기본으로 `사진/GlaNce` 폴더에 저장되고, 설정에서 위치를 바꿀 수 있다.
로그인할 때 자동으로 켜려면 시스템 설정 → 일반 → 로그인 항목에 `GlaNce.app`을 추가한다.

## Project structure

```
GlaNce.swift      앱 전체 소스 (AppKit + SwiftUI + AVFoundation + CoreLocation)
Info.plist        번들 정보, 카메라·위치 권한 문구, Dock 아이콘 숨김
make_icon.swift   앱 아이콘(반사된 g) 생성
build.sh          Universal 빌드 → 아이콘 생성 → 서명 → 설치 (→ zip)
```

## Technical notes

- **Menu bar UI**: `NSStatusItem` + `NSPopover`(detach 지원) 안에 SwiftUI 뷰. 팝업 크기는 `NSHostingController.sizingOptions`로 SwiftUI 뷰 크기를 그대로 따라감
- **Camera**: `AVCaptureSession` 하나를 팝업과 설정 미리보기가 같이 사용하고, 보는 화면이 하나도 없으면 세션 종료 (참조 카운트)
- **Mirroring**: 세션이 실제로 시작된 뒤(`didStartRunningNotification`) preview connection에 좌우반전 적용
- **Capture pipeline**: `AVCapturePhotoOutput` → Core Image로 비율 크롭 · 좌우반전 → Core Graphics로 워터마크 합성 → JPEG 저장 + 클립보드
- **Live overlay**: 미리보기 워터마크를 사진과 같은 비율·여백으로 그려서 찍히는 모습과 일치, `TimelineView`로 1초마다 시간 갱신
- **Location**: `CLLocationManager.requestLocation()` + `CLGeocoder`로 도시 이름, 열 때마다 갱신
- **No Xcode build**: `swiftc` + `lipo`로 Universal 바이너리, `.app` 번들과 `.icns`를 스크립트로 직접 생성
- **Stable ad-hoc signing**: 서명 요구사항을 번들 ID로 고정해서 다시 빌드해도 카메라·위치 권한이 유지됨
- **CLT 호환**: 최신 SDK에서 `@State`가 매크로로 바뀌어 Xcode 없이 빌드가 안 되는 문제를 `ObservableObject`로 우회

## License

[MIT](LICENSE) © 2026 [HongHyun-kr](https://github.com/HongHyun-kr)
