# Gradient for Mac

`web/index.html`을 맥 앱 창(WKWebView)에 띄우는 앱이야. Xcode 없이 Command Line Tools만으로 빌드돼.

## 설치

```bash
xcode-select --install          # 이미 깔려 있으면 생략
cd Gradient-mac
chmod +x build.sh && ./build.sh
cp -R build/Gradient.app /Applications/
open /Applications/Gradient.app
```

처음 열 때 "확인되지 않은 개발자" 경고가 뜨면 Finder에서 우클릭 → 열기.

## 데이터

- 저장 위치: `~/Library/Application Support/Gradient/data.json` (입력할 때마다 자동 저장)
- 자동 백업: 같은 폴더 `backups/`에 하루 1개, 최근 30일치
- 예전 Fluencer 앱 데이터가 있으면 처음 실행할 때 자동으로 복사해 와. 원본 Fluencer 폴더는 그대로 남아.
- 메뉴 **Gradient → Open Data Folder**로 폴더를 열 수 있어.
- 웹 버전 기록 옮기기: 웹 Settings → Full backup (JSON) → 앱 Settings → Open backup file → Restore

## 화면 업데이트

`web/index.html`만 바꾸고 `./build.sh`를 다시 실행하면 돼. 데이터는 앱 밖 폴더라 그대로 남아.

## 단축키

- ⌘Z / ⇧⌘Z: 되돌리기 / 다시 실행
- ⌘= / ⌘- / ⌘0: 확대 / 축소 / 실제 크기
- ⌘R 새로고침, ⌘W 닫기, ⌘Q 종료 (종료 직전에 마지막 입력을 저장)
