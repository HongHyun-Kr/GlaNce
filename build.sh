#!/bin/bash
# GlaNce 빌드 스크립트
# 사용법:  bash build.sh          → 앱 빌드 + 설치
#          bash build.sh --zip    → 위 + 배포용 GlaNce.zip 생성
set -e
cd "$(dirname "$0")"

NAME="GlaNce"
BUNDLE_ID="com.honghyun.glance"

# 응용 프로그램 폴더에 바로 설치 (쓰기 권한 없으면 ~/Applications)
if [ -w /Applications ]; then OUT_DIR="/Applications"; else OUT_DIR="$HOME/Applications"; fi
APP="$OUT_DIR/$NAME.app"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
STAGE="$TMP/$NAME.app"
mkdir -p "$STAGE/Contents/MacOS" "$STAGE/Contents/Resources"

# 1. 컴파일 (Apple Silicon + Intel Universal)
echo "[1/4] 컴파일 중... (1~2분 걸릴 수 있어)"
swiftc -O -parse-as-library -target arm64-apple-macos13.0  "$NAME.swift" -o "$TMP/$NAME-arm64"
swiftc -O -parse-as-library -target x86_64-apple-macos13.0 "$NAME.swift" -o "$TMP/$NAME-x86_64"
lipo -create "$TMP/$NAME-arm64" "$TMP/$NAME-x86_64" -output "$STAGE/Contents/MacOS/$NAME"
chmod +x "$STAGE/Contents/MacOS/$NAME"

# 2. 앱 아이콘 (.icns)
echo "[2/4] 아이콘 만드는 중..."
swift make_icon.swift "$TMP/icon_1024.png" > /dev/null
ICONSET="$TMP/AppIcon.iconset"
mkdir -p "$ICONSET"
for s in 16 32 128 256 512; do
    sips -z $s $s "$TMP/icon_1024.png" --out "$ICONSET/icon_${s}x${s}.png" > /dev/null
    d=$((s * 2))
    sips -z $d $d "$TMP/icon_1024.png" --out "$ICONSET/icon_${s}x${s}@2x.png" > /dev/null
done
iconutil -c icns "$ICONSET" -o "$STAGE/Contents/Resources/AppIcon.icns"

# 3. 서명
# 기본 임시 서명은 빌드할 때마다 바뀌어서 macOS가 카메라/위치 권한 기록을 못 알아봄 (까만 화면 원인)
# → 번들 ID 기준으로 서명 요구사항을 고정해서, 다시 빌드해도 같은 앱으로 인식되게 함
echo "[3/4] 서명 중..."
cp Info.plist "$STAGE/Contents/Info.plist"
xattr -cr "$STAGE"
codesign --force --sign - --identifier "$BUNDLE_ID" \
    --requirements "=designated => identifier \"$BUNDLE_ID\"" "$STAGE"

# 4. 설치 (컴파일이 다 성공한 뒤에만 기존 앱 교체)
echo "[4/4] 설치 중..."
mkdir -p "$OUT_DIR"
rm -rf "$APP"
ditto "$STAGE" "$APP"
touch "$APP"   # Finder 아이콘 캐시 갱신

# 배포용 zip (GitHub Releases에 올릴 파일, 소스 폴더에 생성)
if [ "$1" == "--zip" ]; then
    ZIP="$(pwd)/$NAME.zip"
    rm -f "$ZIP"
    ditto -c -k --keepParent "$APP" "$ZIP"
    echo "배포용 zip: $ZIP"
fi

echo "빌드 완료: $APP"
