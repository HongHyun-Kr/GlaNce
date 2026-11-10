import SwiftUI
import AVFoundation
import AppKit
import CoreImage
import CoreLocation
import CoreText
import Combine

let copyrightOwner = "HongHyun-kr"
let copyrightURL = URL(string: "https://github.com/HongHyun-kr")!
let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "2.0.0"
let maxTopTextLength = 40
let retroOrange = NSColor(srgbRed: 1.0, green: 0.58, blue: 0.16, alpha: 1)

// MARK: - Language

enum AppLanguage: String, CaseIterable, Identifiable {
    case ko, en
    var id: String { rawValue }
    var title: String { self == .ko ? "한국어" : "English" }
}

// 화면 문구: 설정한 언어에 맞춰 한국어/영어 중 하나를 돌려줌
func tr(_ ko: String, _ en: String) -> String {
    AppSettings.shared.language == .ko ? ko : en
}

// MARK: - Options

enum WatermarkFont: String, CaseIterable, Identifiable {
    case avenir, helvetica, sfPro, sfMono, futura, appleGothic, appleMyungjo
    var id: String { rawValue }

    var title: String {
        switch self {
        case .avenir: return "Avenir Next Ultra Light"
        case .helvetica: return "Helvetica Neue Thin"
        case .sfPro: return "SF Pro Light"
        case .sfMono: return "SF Mono Light"
        case .futura: return "Futura Medium"
        case .appleGothic: return "AppleGothic"
        case .appleMyungjo: return "AppleMyungjo"
        }
    }

    // 드롭다운에 보이는 이름 (한글 폰트는 한글 예시도 같이)
    var menuTitle: String {
        switch self {
        case .appleGothic: return "AppleGothic  애플고딕"
        case .appleMyungjo: return "AppleMyungjo  애플명조"
        default: return title
        }
    }

    func font(size: CGFloat) -> NSFont {
        let f: NSFont?
        switch self {
        case .avenir: f = NSFont(name: "AvenirNext-UltraLight", size: size)
        case .helvetica: f = NSFont(name: "HelveticaNeue-Thin", size: size)
        case .sfPro: f = NSFont.systemFont(ofSize: size, weight: .light)
        case .sfMono: f = NSFont.monospacedSystemFont(ofSize: size, weight: .light)
        case .futura: f = NSFont(name: "Futura-Medium", size: size)
        case .appleGothic: f = NSFont(name: "AppleGothic", size: size)
        case .appleMyungjo: f = NSFont(name: "AppleMyungjo", size: size)
        }
        return f ?? NSFont.systemFont(ofSize: size, weight: .light)
    }
}

enum WatermarkPosition: String, CaseIterable, Identifiable {
    case topLeft, topCenter, topRight, center, bottomLeft, bottomCenter, bottomRight
    var id: String { rawValue }

    var title: String {
        switch self {
        case .topLeft: return tr("왼쪽 위", "Top left")
        case .topCenter: return tr("위 가운데", "Top center")
        case .topRight: return tr("오른쪽 위", "Top right")
        case .center: return tr("정가운데", "Center")
        case .bottomLeft: return tr("왼쪽 아래", "Bottom left")
        case .bottomCenter: return tr("아래 가운데", "Bottom center")
        case .bottomRight: return tr("오른쪽 아래", "Bottom right")
        }
    }

    var alignment: Alignment {
        switch self {
        case .topLeft: return .topLeading
        case .topCenter: return .top
        case .topRight: return .topTrailing
        case .center: return .center
        case .bottomLeft: return .bottomLeading
        case .bottomCenter: return .bottom
        case .bottomRight: return .bottomTrailing
        }
    }
}

enum DateStyle: String, CaseIterable, Identifiable {
    case dots, english, film
    var id: String { rawValue }

    var format: String {
        switch self {
        case .dots: return "yyyy.MM.dd"
        case .english: return "MMM d, yyyy"
        case .film: return "''yy MM dd"
        }
    }

    func string(from date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = format
        return f.string(from: date)
    }

    var title: String { string(from: Date()) }
}

enum TimeStyle: String, CaseIterable, Identifiable {
    case h24, h12, seconds
    var id: String { rawValue }

    func string(from date: Date) -> String {
        let f = DateFormatter()
        switch self {
        case .h24:
            f.locale = Locale(identifier: "en_US_POSIX")
            f.dateFormat = "HH:mm"
        case .h12:
            // 한국어면 "오후 5:38", 영어면 "5:38 PM"
            if AppSettings.shared.language == .ko {
                f.locale = Locale(identifier: "ko_KR")
                f.dateFormat = "a h:mm"
            } else {
                f.locale = Locale(identifier: "en_US_POSIX")
                f.dateFormat = "h:mm a"
            }
        case .seconds:
            f.locale = Locale(identifier: "en_US_POSIX")
            f.dateFormat = "HH:mm:ss"
        }
        return f.string(from: date)
    }

    var title: String { string(from: Date()) }
}

enum WatermarkColor: String, CaseIterable, Identifiable {
    case white, black, retro
    var id: String { rawValue }

    var title: String {
        switch self {
        case .white: return tr("흰색", "White")
        case .black: return tr("검정", "Black")
        case .retro: return tr("레트로 주황", "Retro orange")
        }
    }

    var swatch: NSColor {
        switch self {
        case .white: return .white
        case .black: return .black
        case .retro: return retroOrange
        }
    }
}

enum AspectRatio: String, CaseIterable, Identifiable {
    case r16x9, r4x3, r3x2, r1x1
    var id: String { rawValue }

    var title: String {
        switch self {
        case .r16x9: return "16:9"
        case .r4x3: return "4:3"
        case .r3x2: return "3:2"
        case .r1x1: return "1:1"
        }
    }

    var ratio: Double {
        switch self {
        case .r16x9: return 16.0 / 9.0
        case .r4x3: return 4.0 / 3.0
        case .r3x2: return 3.0 / 2.0
        case .r1x1: return 1.0
        }
    }
}

enum MenuIcon: String, CaseIterable, Identifiable {
    case reflectedG, camera, handMirror, sparkles, halfCircle, eye, smile, aperture, heart, moon
    var id: String { rawValue }

    var title: String {
        switch self {
        case .reflectedG: return tr("반사된 g", "Mirrored g")
        case .camera: return tr("카메라", "Camera")
        case .handMirror: return tr("손거울", "Hand mirror")
        case .sparkles: return tr("반짝임", "Sparkles")
        case .halfCircle: return tr("반쪽 원", "Half circle")
        case .eye: return tr("눈", "Eye")
        case .smile: return tr("스마일", "Smile")
        case .aperture: return tr("조리개", "Aperture")
        case .heart: return tr("하트", "Heart")
        case .moon: return tr("달", "Moon")
        }
    }

    func image() -> NSImage {
        switch self {
        case .reflectedG: return makeReflectedGIcon()
        case .handMirror: return makeHandMirrorIcon()
        case .camera: return symbolIcon("camera.fill")
        case .sparkles: return symbolIcon("sparkles")
        case .halfCircle: return symbolIcon("circle.lefthalf.filled")
        case .eye: return symbolIcon("eye")
        case .smile: return symbolIcon("face.smiling")
        case .aperture: return symbolIcon("camera.aperture")
        case .heart: return symbolIcon("heart")
        case .moon: return symbolIcon("moon")
        }
    }
}

// MARK: - Watermark style (촬영 시점 스냅샷 겸 미리보기용)

struct WatermarkStyle {
    var enabled: Bool
    var showDate: Bool
    var showPlace: Bool
    var uppercase: Bool
    var dateStyle: DateStyle
    var showTime: Bool
    var timeStyle: TimeStyle
    var font: WatermarkFont
    var sizePct: Double
    var topSizePct: Double
    var opacity: Double
    var kernPct: Double
    var position: WatermarkPosition
    var color: WatermarkColor

    // 화면 가장자리 여백 (사진 높이 대비)
    static let stampMargin: CGFloat = 0.055     // 날짜·위치
    static let captionMargin: CGFloat = 0.035   // 상단 문구
    static let stackGap: CGFloat = 0.012        // 위 가운데일 때 문구와 날짜 사이

    // 레트로: 폰트·날짜 형식 자동, 위치 정보 제외
    var isRetro: Bool { color == .retro }

    func nsFont(size: CGFloat) -> NSFont {
        isRetro ? NSFont.monospacedSystemFont(ofSize: size, weight: .semibold) : font.font(size: size)
    }

    var textColor: NSColor {
        color.swatch.withAlphaComponent(CGFloat(opacity / 100))
    }

    var glowColor: NSColor {
        switch color {
        case .white: return NSColor.black.withAlphaComponent(0.3)
        case .black: return NSColor.white.withAlphaComponent(0.3)
        case .retro: return retroOrange.withAlphaComponent(0.75)
        }
    }

    func glowRadius(_ size: CGFloat) -> CGFloat { isRetro ? size * 0.35 : size * 0.2 }

    func bottomText(date: Date, place: String?) -> String? {
        guard enabled else { return nil }
        var parts: [String] = []
        // 날짜와 시간은 한 묶음으로 (날짜 바로 옆에 시간)
        var when: [String] = []
        if showDate { when.append((isRetro ? DateStyle.film : dateStyle).string(from: date)) }
        if showTime { when.append(timeStyle.string(from: date)) }
        if !when.isEmpty { parts.append(when.joined(separator: "  ")) }
        if showPlace && !isRetro, let p = place, !p.isEmpty { parts.append(p) }
        guard !parts.isEmpty else { return nil }
        let t = parts.joined(separator: "   ")
        return uppercase ? t.uppercased() : t
    }

    func topText(_ raw: String, enabled topOn: Bool) -> String? {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard topOn, !t.isEmpty else { return nil }
        return uppercase ? t.uppercased() : t
    }
}

// MARK: - Settings (UserDefaults에 저장, 앱을 다시 켜도 유지)

final class AppSettings: ObservableObject {
    static let shared = AppSettings()
    private let d = UserDefaults.standard

    static let defaultDir: URL = FileManager.default
        .urls(for: .picturesDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("GlaNce", isDirectory: true)

    // 창 크기 단계 (1~10, 높이 기준. 비율이 바뀌어도 높이는 그대로)
    static let popHeights: [Double] = [120, 145, 170, 200, 240, 285, 335, 390, 450, 520]
    static let defaultPopSize = 3

    // 일반
    @Published var language: AppLanguage { didSet { d.set(language.rawValue, forKey: "language") } }
    @Published var copyToClipboard: Bool { didSet { d.set(copyToClipboard, forKey: "copyToClipboard") } }
    @Published var timerSeconds: Int { didSet { d.set(timerSeconds, forKey: "timerSeconds") } }
    @Published var aspect: AspectRatio { didSet { d.set(aspect.rawValue, forKey: "aspect") } }
    @Published var popSize: Int { didSet { d.set(popSize, forKey: "popSize") } }
    var popHeight: Double { AppSettings.popHeights[min(10, max(1, popSize)) - 1] }
    var popWidth: Double { popHeight * aspect.ratio }

    // 날짜·위치 표시
    @Published var wmEnabled: Bool { didSet { d.set(wmEnabled, forKey: "wmEnabled") } }
    @Published var livePreview: Bool { didSet { d.set(livePreview, forKey: "livePreview") } }
    @Published var showDate: Bool { didSet { d.set(showDate, forKey: "wmShowDate") } }
    @Published var showPlace: Bool { didSet { d.set(showPlace, forKey: "wmShowPlace") } }
    @Published var uppercase: Bool { didSet { d.set(uppercase, forKey: "wmUppercase") } }
    @Published var dateStyle: DateStyle { didSet { d.set(dateStyle.rawValue, forKey: "wmDateStyle") } }
    @Published var showTime: Bool { didSet { d.set(showTime, forKey: "wmShowTime") } }
    @Published var timeStyle: TimeStyle { didSet { d.set(timeStyle.rawValue, forKey: "wmTimeStyle") } }
    @Published var wmFont: WatermarkFont { didSet { d.set(wmFont.rawValue, forKey: "wmFont") } }
    @Published var sizePct: Double { didSet { d.set(sizePct, forKey: "wmSizePct") } }
    @Published var opacity: Double { didSet { d.set(opacity, forKey: "wmOpacity") } }
    @Published var kernPct: Double { didSet { d.set(kernPct, forKey: "wmKern") } }
    @Published var position: WatermarkPosition { didSet { d.set(position.rawValue, forKey: "wmPosition") } }
    @Published var wmColor: WatermarkColor { didSet { d.set(wmColor.rawValue, forKey: "wmColor") } }

    // 상단 문구 (한 줄, 최대 40자)
    @Published var topEnabled: Bool { didSet { d.set(topEnabled, forKey: "topEnabled") } }
    @Published var topSizePct: Double { didSet { d.set(topSizePct, forKey: "topSizePct") } }
    @Published var topText: String {
        didSet {
            let cleaned = String(topText.replacingOccurrences(of: "\n", with: " ").prefix(maxTopTextLength))
            if cleaned != topText { topText = cleaned }
            d.set(topText, forKey: "topText")
        }
    }

    // 기타
    @Published var menuIcon: MenuIcon { didSet { d.set(menuIcon.rawValue, forKey: "menuIcon") } }
    @Published private(set) var saveDir: URL

    private init() {
        let d = UserDefaults.standard     // 모든 프로퍼티 초기화 전이라 self.d 대신 지역 변수 사용
        let systemKorean = Locale.preferredLanguages.first?.hasPrefix("ko") ?? false
        d.register(defaults: [
            "language": systemKorean ? AppLanguage.ko.rawValue : AppLanguage.en.rawValue,
            "copyToClipboard": true, "timerSeconds": 0,
            "aspect": AspectRatio.r16x9.rawValue, "popSize": AppSettings.defaultPopSize,
            "wmEnabled": true, "livePreview": true,
            "wmShowDate": true, "wmShowTime": true, "wmTimeStyle": TimeStyle.h24.rawValue,
            "wmShowPlace": true, "wmUppercase": true,
            "wmDateStyle": DateStyle.dots.rawValue, "wmFont": WatermarkFont.avenir.rawValue,
            "wmSizePct": 4.0, "wmOpacity": 70.0, "wmKern": 22.0,
            "wmPosition": WatermarkPosition.bottomLeft.rawValue, "wmColor": WatermarkColor.white.rawValue,
            "topEnabled": true, "topSizePct": 4.0, "topText": "",
            "menuIcon": MenuIcon.reflectedG.rawValue
        ])
        language = AppLanguage(rawValue: d.string(forKey: "language") ?? "") ?? .ko
        copyToClipboard = d.bool(forKey: "copyToClipboard")
        timerSeconds = min(5, max(0, d.integer(forKey: "timerSeconds")))
        aspect = AspectRatio(rawValue: d.string(forKey: "aspect") ?? "") ?? .r16x9
        popSize = min(10, max(1, d.integer(forKey: "popSize")))
        wmEnabled = d.bool(forKey: "wmEnabled")
        livePreview = d.bool(forKey: "livePreview")
        showDate = d.bool(forKey: "wmShowDate")
        showTime = d.bool(forKey: "wmShowTime")
        timeStyle = TimeStyle(rawValue: d.string(forKey: "wmTimeStyle") ?? "") ?? .h24
        showPlace = d.bool(forKey: "wmShowPlace")
        uppercase = d.bool(forKey: "wmUppercase")
        dateStyle = DateStyle(rawValue: d.string(forKey: "wmDateStyle") ?? "") ?? .dots
        wmFont = WatermarkFont(rawValue: d.string(forKey: "wmFont") ?? "") ?? .avenir
        sizePct = d.double(forKey: "wmSizePct")
        opacity = d.double(forKey: "wmOpacity")
        kernPct = d.double(forKey: "wmKern")
        position = WatermarkPosition(rawValue: d.string(forKey: "wmPosition") ?? "") ?? .bottomLeft
        wmColor = WatermarkColor(rawValue: d.string(forKey: "wmColor") ?? "") ?? .white
        topEnabled = d.bool(forKey: "topEnabled")
        topSizePct = d.double(forKey: "topSizePct")
        topText = d.string(forKey: "topText") ?? ""
        menuIcon = MenuIcon(rawValue: d.string(forKey: "menuIcon") ?? "") ?? .reflectedG
        saveDir = d.url(forKey: "saveDir") ?? AppSettings.defaultDir
    }

    var style: WatermarkStyle {
        WatermarkStyle(enabled: wmEnabled, showDate: showDate, showPlace: showPlace, uppercase: uppercase,
                       dateStyle: dateStyle, showTime: showTime, timeStyle: timeStyle, font: wmFont, sizePct: sizePct, topSizePct: topSizePct,
                       opacity: opacity, kernPct: kernPct, position: position, color: wmColor)
    }

    func resetCaption() {
        topEnabled = true; topSizePct = 4.0; topText = ""
    }

    func resetWatermark() {
        wmEnabled = true; livePreview = true; showDate = true; showPlace = true; uppercase = true
        dateStyle = .dots; showTime = true; timeStyle = .h24; wmFont = .avenir; sizePct = 4.0; opacity = 70; kernPct = 22
        position = .bottomLeft; wmColor = .white
    }

    // 저장 위치
    func chooseSaveDir() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = tr("선택", "Choose")
        panel.message = tr("사진을 저장할 폴더를 선택하세요", "Choose a folder for your photos")
        panel.directoryURL = saveDir
        NSApp.activate(ignoringOtherApps: true)
        guard panel.runModal() == .OK, let url = panel.url else { return }
        saveDir = url
        d.set(url, forKey: "saveDir")
    }

    func resetSaveDir() {
        d.removeObject(forKey: "saveDir")
        saveDir = AppSettings.defaultDir
    }

    func openSaveDir() {
        try? FileManager.default.createDirectory(at: saveDir, withIntermediateDirectories: true)
        NSWorkspace.shared.open(saveDir)
    }

    var saveDirDisplay: String {
        saveDir.path.replacingOccurrences(of: NSHomeDirectory(), with: "~")
    }
}

let settings = AppSettings.shared
let sharedCamera = CameraModel()

// MARK: - Camera

// 셔터 누른 순간의 설정값
struct CaptureSnapshot {
    var place: String?
    var dir: URL
    var style: WatermarkStyle
    var top: String?
    var aspect: CGFloat
    var copy: Bool
}

final class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate, CLLocationManagerDelegate {
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let queue = DispatchQueue(label: "glance.camera")
    private var configured = false
    private var hasInput = false
    private var wanted = false
    private var clients = 0                               // 카메라를 보고 있는 화면 수 (팝업, 설정 창)
    private var statusClear: DispatchWorkItem?
    private var errorObserver: NSObjectProtocol?
    private var pending: [Int64: CaptureSnapshot] = [:]   // camera queue

    // 워터마크용 위치
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    @Published private(set) var placeName: String?
    @Published private(set) var locationAuth: CLAuthorizationStatus = .notDetermined
    private var lastPlaceRequest = Date.distantPast

    // 화면 표시용 상태
    enum CameraState: Equatable {
        case idle, requesting, denied, noDevice, starting, running
        case failed(String)
    }
    @Published private(set) var cameraState: CameraState = .idle
    @Published private(set) var countdown = 0
    @Published private(set) var flashCount = 0
    @Published var status = ""
    private var countdownTimer: Timer?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationAuth = locationManager.authorizationStatus
        errorObserver = NotificationCenter.default.addObserver(
            forName: AVCaptureSession.runtimeErrorNotification, object: session, queue: .main
        ) { [weak self] note in
            let err = note.userInfo?[AVCaptureSessionErrorKey] as? Error
            self?.cameraState = .failed(err?.localizedDescription ?? tr("카메라 오류", "Camera error"))
        }
    }

    var stateMessage: String? {
        switch cameraState {
        case .running, .idle: return nil
        case .requesting: return tr("카메라 권한을 요청하고 있어요\n뜨는 창에서 '허용'을 눌러주세요",
                                    "Asking for camera access\nClick 'Allow' in the dialog")
        case .starting: return tr("카메라 켜는 중…", "Starting camera…")
        case .denied: return tr("카메라 권한이 꺼져 있어요", "Camera access is turned off")
        case .noDevice: return tr("카메라를 찾을 수 없어요", "No camera found")
        case .failed(let msg): return msg
        }
    }

    // 앱 실행 직후 권한부터 받기 (카메라 → 위치 순서)
    func requestPermissionsOnLaunch() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { _ in
                DispatchQueue.main.async { self.refreshPlace() }
            }
        } else {
            refreshPlace()
        }
    }

    // 팝업이나 설정 창 중 하나라도 보이는 동안 카메라 유지
    func acquire() {
        clients += 1
        if clients == 1 { start() }
    }

    func release() {
        clients = max(0, clients - 1)
        if clients == 0 { stop() }
    }

    private func start() {
        wanted = true
        refreshPlace()                 // 열 때마다 위치 갱신
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraState = .starting
            queue.async {
                let ok = self.configureIfNeeded()
                guard ok else {
                    DispatchQueue.main.async { self.cameraState = .noDevice }
                    return
                }
                if !self.session.isRunning { self.session.startRunning() }
                let running = self.session.isRunning
                DispatchQueue.main.async {
                    guard self.wanted else { return }
                    self.cameraState = running ? .running
                        : .failed(tr("카메라를 켤 수 없어요\n다른 앱이 쓰고 있는지 확인해주세요",
                                     "Couldn't start the camera\nCheck if another app is using it"))
                }
            }
        case .notDetermined:
            cameraState = .requesting
            AVCaptureDevice.requestAccess(for: .video) { ok in
                DispatchQueue.main.async {
                    if !ok { self.cameraState = .denied; return }
                    if self.wanted { self.start() } else { self.cameraState = .idle }
                }
            }
        default:
            cameraState = .denied
        }
    }

    private func stop() {
        wanted = false
        cancelCountdown()
        if cameraState != .denied { cameraState = .idle }
        queue.async {
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    // camera queue에서 호출. 카메라 입력이 붙어 있으면 true
    private func configureIfNeeded() -> Bool {
        guard !configured else { return hasInput }
        session.beginConfiguration()
        session.sessionPreset = .high
        if let device = AVCaptureDevice.default(for: .video),
           let input = try? AVCaptureDeviceInput(device: device),
           session.canAddInput(input) {
            session.addInput(input)
            hasInput = true
        }
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        session.commitConfiguration()
        configured = true
        return hasInput
    }

    // MARK: Shutter + timer

    // 셔터 버튼 / 스페이스바. 카운트다운 중에 다시 누르면 취소
    func shoot() {
        if countdown > 0 { cancelCountdown(); return }
        guard cameraState == .running else { return }
        let t = settings.timerSeconds
        guard t > 0 else { capture(); return }
        countdown = t
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] tm in
            guard let self = self else { tm.invalidate(); return }
            self.countdown -= 1
            if self.countdown <= 0 {
                tm.invalidate()
                self.countdownTimer = nil
                self.capture()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        countdownTimer = timer
    }

    func cancelCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        countdown = 0
    }

    private func capture() {
        // 분리 창을 오래 켜둔 경우 대비: 5분 지났으면 위치 다시 요청
        if Date().timeIntervalSince(lastPlaceRequest) > 300 { refreshPlace() }
        let style = settings.style
        let snap = CaptureSnapshot(place: placeName,
                                   dir: settings.saveDir,
                                   style: style,
                                   top: style.topText(settings.topText, enabled: settings.topEnabled),
                                   aspect: CGFloat(settings.aspect.ratio),
                                   copy: settings.copyToClipboard)
        flashCount += 1
        queue.async {
            guard self.session.isRunning else { return }
            let photoSettings = AVCapturePhotoSettings()
            self.pending[photoSettings.uniqueID] = snap
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        let id = photo.resolvedSettings.uniqueID
        // 이 콜백은 AVFoundation 내부 스레드에서 오니까 pending은 camera queue에서만 만짐
        guard let snap = queue.sync(execute: { pending.removeValue(forKey: id) }) else { return }
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              var image = CIImage(data: data) else {
            setStatus(tr("촬영 실패", "Capture failed"))
            return
        }

        // 미리보기와 같은 비율로 가운데 크롭
        let e = image.extent
        var crop = e
        if e.width / e.height > snap.aspect {
            let w = e.height * snap.aspect
            crop = CGRect(x: e.minX + (e.width - w) / 2, y: e.minY, width: w, height: e.height)
        } else {
            let h = e.width / snap.aspect
            crop = CGRect(x: e.minX, y: e.minY + (e.height - h) / 2, width: e.width, height: h)
        }
        image = image.cropped(to: crop)
            .transformed(by: CGAffineTransform(translationX: -crop.minX, y: -crop.minY))

        // 거울처럼 좌우반전 (미리보기와 동일)
        let w = image.extent.width
        image = image.transformed(by: CGAffineTransform(scaleX: -1, y: 1).translatedBy(x: -w, y: 0))

        let bottom = snap.style.bottomText(date: Date(), place: snap.place)
        guard let rendered = render(image, bottom: bottom, top: snap.top, style: snap.style) else {
            setStatus(tr("변환 실패", "Processing failed"))
            return
        }
        let rep = NSBitmapImageRep(cgImage: rendered)
        guard let jpg = rep.representation(using: .jpeg, properties: [.compressionFactor: 0.92]) else {
            setStatus(tr("변환 실패", "Processing failed"))
            return
        }

        do {
            try FileManager.default.createDirectory(at: snap.dir, withIntermediateDirectories: true)
            let f = DateFormatter()
            f.dateFormat = "yyyyMMdd_HHmmss"
            let url = snap.dir.appendingPathComponent("GlaNce_\(f.string(from: Date())).jpg")
            try jpg.write(to: url)
        } catch {
            setStatus(tr("저장 실패", "Save failed"), sticky: true)
            return
        }

        if snap.copy {
            // 찍자마자 ⌘V로 바로 붙여넣기
            let tiff = rep.tiffRepresentation
            DispatchQueue.main.async {
                let pb = NSPasteboard.general
                pb.clearContents()
                let item = NSPasteboardItem()
                if let tiff = tiff { item.setData(tiff, forType: .tiff) }
                item.setData(jpg, forType: NSPasteboard.PasteboardType("public.jpeg"))
                pb.writeObjects([item])
            }
        }
        setStatus(tr("저장됨", "Saved"))
    }

    // MARK: Watermark rendering

    private func render(_ image: CIImage, bottom: String?, top: String?, style: WatermarkStyle) -> CGImage? {
        guard let cs = CGColorSpace(name: CGColorSpace.sRGB),
              let cg = CIContext().createCGImage(image, from: image.extent) else { return nil }
        guard bottom != nil || top != nil else { return cg }

        let W = CGFloat(cg.width), H = CGFloat(cg.height)
        guard let ctx = CGContext(data: nil, width: cg.width, height: cg.height, bitsPerComponent: 8, bytesPerRow: 0,
                                  space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: W, height: H))

        func attrs(size: CGFloat) -> (attrs: [NSAttributedString.Key: Any], kern: CGFloat) {
            let kern = size * CGFloat(style.kernPct) / 100
            let shadow = NSShadow()
            shadow.shadowColor = style.glowColor
            shadow.shadowBlurRadius = style.glowRadius(size)
            shadow.shadowOffset = .zero
            return ([.font: style.nsFont(size: size), .kern: kern,
                     .foregroundColor: style.textColor, .shadow: shadow], kern)
        }

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)

        // 상단 문구: 위 가운데
        var captionBottomY: CGFloat?
        if let t = top {
            let a = attrs(size: H * CGFloat(style.topSizePct) / 100)
            let str = NSAttributedString(string: t, attributes: a.attrs)
            let ts = str.size()
            let y = H - H * WatermarkStyle.captionMargin - ts.height
            str.draw(at: NSPoint(x: (W - (ts.width - a.kern)) / 2, y: y))
            captionBottomY = y
        }

        // 날짜·위치
        if let b = bottom {
            let a = attrs(size: H * CGFloat(style.sizePct) / 100)
            let str = NSAttributedString(string: b, attributes: a.attrs)
            let ts = str.size()
            let tw = ts.width - a.kern          // 마지막 글자 뒤 자간 제외
            let m = H * WatermarkStyle.stampMargin
            let x: CGFloat
            switch style.position {
            case .topLeft, .bottomLeft: x = m
            case .topCenter, .center, .bottomCenter: x = (W - tw) / 2
            case .topRight, .bottomRight: x = W - m - tw
            }
            let y: CGFloat
            switch style.position {
            case .topLeft, .topRight: y = H - m - ts.height
            case .topCenter:
                // 상단 문구가 있으면 그 바로 아래
                if let cy = captionBottomY { y = cy - H * WatermarkStyle.stackGap - ts.height }
                else { y = H - m - ts.height }
            case .center: y = (H - ts.height) / 2
            case .bottomLeft, .bottomCenter, .bottomRight: y = m
            }
            str.draw(at: NSPoint(x: x, y: y))
        }

        NSGraphicsContext.restoreGraphicsState()
        return ctx.makeImage()
    }

    // MARK: Location

    func refreshPlace() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorized:
            lastPlaceRequest = Date()
            locationManager.requestLocation()
        default:
            break   // 거부 시 날짜만 표시
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let s = manager.authorizationStatus
        DispatchQueue.main.async { self.locationAuth = s }
        if s == .authorizedAlways || s == .authorized {
            lastPlaceRequest = Date()
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(loc, preferredLocale: Locale(identifier: "en_US")) { marks, _ in
            guard let m = marks?.first else { return }
            let name = m.locality ?? m.administrativeArea ?? m.country
            DispatchQueue.main.async { self.placeName = name }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}

    func setStatus(_ s: String, sticky: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.statusClear?.cancel()
            self.status = s
            guard !sticky else { return }
            let item = DispatchWorkItem { [weak self] in self?.status = "" }
            self.statusClear = item
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: item)
        }
    }
}

// MARK: - Camera preview layer

final class PreviewView: NSView {
    let previewLayer = AVCaptureVideoPreviewLayer()
    private var startObserver: NSObjectProtocol?

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        previewLayer.videoGravity = .resizeAspectFill
        layer?.addSublayer(previewLayer)

        // 카메라가 실제로 켜진 뒤에야 connection이 생기므로 그때 반전 적용
        startObserver = NotificationCenter.default.addObserver(
            forName: AVCaptureSession.didStartRunningNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.applyMirror()
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    deinit {
        if let o = startObserver { NotificationCenter.default.removeObserver(o) }
    }

    // 영상 부분을 잡고 끌면 팝오버 분리 / 창 이동
    override var mouseDownCanMoveWindow: Bool { true }

    override func layout() {
        super.layout()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        previewLayer.frame = bounds
        CATransaction.commit()
        applyMirror()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        applyMirror()
    }

    func applyMirror() {
        guard let c = previewLayer.connection, c.isVideoMirroringSupported else { return }
        c.automaticallyAdjustsVideoMirroring = false
        c.isVideoMirrored = true
    }
}

struct CameraPreview: NSViewRepresentable {
    let camera: CameraModel

    func makeNSView(context: Context) -> PreviewView {
        let v = PreviewView()
        v.previewLayer.session = camera.session
        return v
    }

    func updateNSView(_ v: PreviewView, context: Context) {
        v.applyMirror()
    }
}

// MARK: - Watermark overlay (실시간 화면 + 설정 미리보기 공용, 사진에 찍히는 위치와 동일)

struct WatermarkOverlay: View {
    let style: WatermarkStyle
    let bottom: String?
    let top: String?
    let height: CGFloat

    var body: some View {
        let fs = height * CGFloat(style.sizePct) / 100
        let capFs = height * CGFloat(style.topSizePct) / 100
        let m = height * WatermarkStyle.stampMargin
        let stacked = style.position == .topCenter && top != nil
        ZStack {
            if let b = bottom, !stacked {
                label(b, fs)
                    .padding(m)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: style.position.alignment)
            }
            if let t = top {
                VStack(spacing: height * WatermarkStyle.stackGap) {
                    label(t, capFs)
                    // 날짜·위치가 '위 가운데'면 상단 문구 바로 아래에
                    if stacked, let b = bottom {
                        label(b, fs)
                    }
                }
                .padding(.top, height * WatermarkStyle.captionMargin)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .allowsHitTesting(false)
    }

    private func label(_ s: String, _ fs: CGFloat) -> some View {
        Text(s)
            .font(Font(style.nsFont(size: fs) as CTFont))
            .kerning(fs * CGFloat(style.kernPct) / 100)
            .foregroundStyle(Color(nsColor: style.textColor))
            .shadow(color: Color(nsColor: style.glowColor), radius: style.glowRadius(fs))
            .lineLimit(1)
            .fixedSize()
    }
}

// MARK: - Popover content

// 팝업 화면 상태
// (최신 SDK에서 @State가 매크로로 바뀌어서 Xcode 없이 빌드하면 안 되기 때문에 ObservableObject로 대체)
final class PopoverUIState: ObservableObject {
    @Published var editingTop = false
    @Published var flashOpacity: Double = 0
    var dragStart: (point: NSPoint, size: Double)?
    var cursorPushed = false
}

let popoverUI = PopoverUIState()

struct GlaNceView: View {
    @ObservedObject var camera: CameraModel
    @ObservedObject var settings: AppSettings
    @ObservedObject var ui: PopoverUIState
    let openSettings: () -> Void
    @FocusState private var topFocused: Bool

    private var width: CGFloat { CGFloat(settings.popWidth) }
    private var height: CGFloat { CGFloat(settings.popHeight) }

    var body: some View {
        let style = settings.style
        ZStack {
            CameraPreview(camera: camera)

            // 실시간 워터마크
            if settings.livePreview && camera.cameraState == .running {
                TimelineView(.periodic(from: Date(), by: 1)) { tl in
                    WatermarkOverlay(style: style,
                                     bottom: style.bottomText(date: tl.date, place: camera.placeName),
                                     top: ui.editingTop ? nil : style.topText(settings.topText, enabled: settings.topEnabled),
                                     height: height)
                }
            }

            // 카메라가 안 켜졌을 때 이유 표시
            if let msg = camera.stateMessage {
                stateView(msg)
            }

            // 타이머 카운트다운
            if camera.countdown > 0 {
                Text("\(camera.countdown)")
                    .font(.system(size: height * 0.32, weight: .ultraLight))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 6)
                    .allowsHitTesting(false)
            }

            // 입력 중에 팝업 다른 곳을 누르면 입력 끝내고 적용된 모습으로
            if ui.editingTop {
                Color.black.opacity(0.001)
                    .contentShape(Rectangle())
                    .onTapGesture { ui.editingTop = false }
            }

            // 상단 문구 자리를 더블클릭하면 바로 수정
            if settings.topEnabled && !ui.editingTop {
                Color.black.opacity(0.001)
                    .frame(width: width * 0.6, height: max(28, height * 0.2))
                    .contentShape(Rectangle())
                    .onTapGesture(count: 2) { ui.editingTop = true }
                    .help(tr("더블클릭해서 상단 문구 수정", "Double-click to edit the caption"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }

            // 엔터로도 촬영 (문구 입력 중엔 엔터가 입력 완료로만 동작)
            Button("") { camera.shoot() }
                .keyboardShortcut(ui.editingTop ? nil : KeyboardShortcut(.return, modifiers: []))
                .buttonStyle(.plain)
                .focusable(false)
                .opacity(0)
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)

            controls

            if ui.editingTop {
                topEditor
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 8)
            }

            // 촬영 플래시
            Color.white
                .opacity(ui.flashOpacity)
                .allowsHitTesting(false)

            resizeGrip
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .frame(width: width, height: height)
        .onChange(of: camera.flashCount) { _ in
            ui.flashOpacity = 0.85
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.45)) { ui.flashOpacity = 0 }
            }
        }
        .onChange(of: ui.editingTop) { on in
            if on { DispatchQueue.main.async { topFocused = true } }
        }
        .onChange(of: settings.topEnabled) { on in
            if !on { ui.editingTop = false }
        }
    }

    // MARK: Controls

    private var controls: some View {
        VStack {
            HStack(spacing: 6) {
                if settings.topEnabled {
                    captionButton
                }
                Spacer()
                overlayButton("gearshape.circle.fill", size: 18, action: openSettings)
                    .help(tr("설정", "Settings"))
                overlayButton("power.circle.fill", size: 18) { NSApp.terminate(nil) }
                    .help(tr("종료", "Quit"))
            }
            Spacer()
            HStack(alignment: .bottom, spacing: 8) {
                if !camera.status.isEmpty {
                    Text(camera.status)
                        .font(.caption2)
                        .lineLimit(1)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                Spacer()
                HStack(spacing: 2) {
                    overlayButton("folder.circle.fill", size: 22) { settings.openSaveDir() }
                        .help(tr("저장 폴더 열기", "Open save folder"))
                    Button { camera.shoot() } label: {
                        Image(systemName: camera.countdown > 0 ? "stop.circle.fill" : "camera.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2)
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                    .keyboardShortcut(ui.editingTop ? nil : KeyboardShortcut(.space, modifiers: []))
                    .help(tr("촬영 (스페이스바 / 엔터)", "Shoot (Space / Return)"))
                    // 타이머: 셔터 위, 오른쪽 끝을 셔터 오른쪽 끝에 맞춤 ('3s'가 붙으면 왼쪽으로 늘어남)
                    .overlay(alignment: .topTrailing) {
                        timerButton
                            .fixedSize()            // 셔터 폭에 눌려서 줄바꿈되지 않게
                            .offset(y: -22)
                    }
                }
            }
            .padding(.trailing, 10)
        }
        .padding(8)
    }

    // 좌상단 문구 버튼: 한국어면 가I, 영어면 AI
    private var captionButton: some View {
        Button { ui.editingTop.toggle() } label: {
            ZStack {
                Circle().fill(ui.editingTop ? Color.accentColor : Color.white)
                HStack(spacing: 0) {
                    Text(settings.language == .ko ? "가" : "A")
                        .font(.system(size: 8, weight: .bold))
                    Text("I")
                        .font(.system(size: 10, weight: .regular, design: .serif))
                }
                .foregroundStyle(ui.editingTop ? Color.white : Color.black.opacity(0.75))
            }
            .frame(width: 18, height: 18)
            .shadow(color: .black.opacity(0.5), radius: 2)
        }
        .buttonStyle(.plain)
        .focusable(false)
        .help(tr("상단 문구 입력", "Add a caption"))
    }

    private var timerButton: some View {
        Button {
            let options = [0, 3, 5]
            settings.timerSeconds = options.first { $0 > settings.timerSeconds } ?? 0
        } label: {
            HStack(spacing: 2) {
                Image(systemName: "timer")
                    .font(.system(size: 12, weight: .semibold))
                if settings.timerSeconds > 0 {
                    Text("\(settings.timerSeconds)s")
                        .font(.system(size: 11, weight: .semibold))
                        .lineLimit(1)
                        .fixedSize()
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(settings.timerSeconds > 0 ? Color.white.opacity(0.25) : Color.clear, in: Capsule())
            .shadow(color: .black.opacity(0.5), radius: 2)
        }
        .buttonStyle(.plain)
        .focusable(false)
        .help(tr("타이머 (끔 → 3초 → 5초)", "Timer (off → 3s → 5s)"))
    }

    private var topEditor: some View {
        HStack(spacing: 6) {
            TextField(tr("짧은 문구 입력 후 Enter", "Type a caption, then Enter"), text: $settings.topText)
                .textFieldStyle(.plain)
                .multilineTextAlignment(.center)
                .font(.system(size: 13))
                .foregroundStyle(.white)
                .focused($topFocused)
                .onSubmit { ui.editingTop = false }
                .onExitCommand { ui.editingTop = false }
            if !settings.topText.isEmpty {
                Button { settings.topText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.black.opacity(0.5), in: Capsule())
        .frame(width: min(width * 0.62, 320))
    }

    // 우하단 모서리: 보이지 않는 영역, 마우스를 올리면 대각선 크기 조절 커서
    private var resizeGrip: some View {
        Color.clear
            .frame(width: 18, height: 18)
            .contentShape(Rectangle())
            .onHover { inside in
                if inside && !ui.cursorPushed {
                    diagonalResizeCursor().push()
                    ui.cursorPushed = true
                } else if !inside && ui.cursorPushed && ui.dragStart == nil {
                    NSCursor.pop()
                    ui.cursorPushed = false
                }
            }
            .gesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { _ in
                        // 팝업 위치가 같이 움직이니까 화면 좌표 기준으로 계산
                        let p = NSEvent.mouseLocation
                        if ui.dragStart == nil { ui.dragStart = (point: p, size: settings.popHeight) }
                        guard let s = ui.dragStart else { return }
                        diagonalResizeCursor().set()
                        let dy = Double(s.point.y - p.y)                                  // 아래로 끌면 커짐
                        let dx = Double(p.x - s.point.x) * 2 / settings.aspect.ratio      // 팝업은 아이콘 기준 가운데 정렬
                        let target = s.size + max(dx, dy)
                        // 1~10 단계 중 가장 가까운 높이로
                        var best = 1
                        for (i, h) in AppSettings.popHeights.enumerated()
                            where abs(h - target) < abs(AppSettings.popHeights[best - 1] - target) {
                            best = i + 1
                        }
                        if best != settings.popSize { settings.popSize = best }
                    }
                    .onEnded { _ in
                        ui.dragStart = nil
                        if ui.cursorPushed {
                            NSCursor.pop()
                            ui.cursorPushed = false
                        }
                    }
            )
    }

    private func stateView(_ msg: String) -> some View {
        VStack(spacing: 8) {
            if camera.cameraState == .starting || camera.cameraState == .requesting {
                ProgressView().controlSize(.small)
            }
            Text(msg)
                .font(.caption)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            if camera.cameraState == .denied {
                Button(tr("시스템 설정 열기", "Open System Settings")) { openPrivacySettings("Privacy_Camera") }
                    .controlSize(.small)
            }
        }
        .padding(.horizontal, 28)
    }

    private func overlayButton(_ symbol: String, size: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: size))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.5), radius: 2)
        }
        .buttonStyle(.plain)
        .focusable(false)
    }
}

// MARK: - Native pop-up menu (항목마다 실제 폰트/색상 표시)

// 선택된 항목 길이에 맞춰 너비가 줄어드는 팝업 버튼 (긴 항목 때문에 생기는 빈 여백 제거)
final class FitPopUpButton: NSPopUpButton {
    override var intrinsicContentSize: NSSize {
        let base = super.intrinsicContentSize
        guard let item = selectedItem else { return base }
        let title = item.attributedTitle
            ?? NSAttributedString(string: item.title, attributes: [.font: font ?? NSFont.systemFont(ofSize: 13)])
        return NSSize(width: ceil(title.size().width) + 38, height: base.height)
    }
}

struct PopUpPicker: NSViewRepresentable {
    let titles: [NSAttributedString]
    @Binding var selectedIndex: Int

    func makeCoordinator() -> Coordinator { Coordinator(selectedIndex: $selectedIndex) }

    func makeNSView(context: Context) -> FitPopUpButton {
        let b = FitPopUpButton(frame: .zero, pullsDown: false)
        b.target = context.coordinator
        b.action = #selector(Coordinator.changed(_:))
        return b
    }

    func updateNSView(_ b: FitPopUpButton, context: Context) {
        context.coordinator.selectedIndex = $selectedIndex
        b.isEnabled = context.environment.isEnabled
        let menu = NSMenu()
        for t in titles {
            let item = NSMenuItem(title: t.string, action: nil, keyEquivalent: "")
            item.attributedTitle = t
            menu.addItem(item)
        }
        b.menu = menu
        if selectedIndex >= 0 && selectedIndex < titles.count {
            b.selectItem(at: selectedIndex)
        }
        b.invalidateIntrinsicContentSize()
    }

    final class Coordinator: NSObject {
        var selectedIndex: Binding<Int>
        init(selectedIndex: Binding<Int>) { self.selectedIndex = selectedIndex }
        @objc func changed(_ sender: NSPopUpButton) {
            selectedIndex.wrappedValue = sender.indexOfSelectedItem
            sender.invalidateIntrinsicContentSize()
        }
    }
}

// MARK: - Settings window

enum SettingsTab: String, CaseIterable, Identifiable {
    case general, stamp, caption, saving, access, menuIcon
    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: return tr("일반", "General")
        case .stamp: return tr("날짜·위치 표시", "Date & place")
        case .caption: return tr("상단 문구", "Caption")
        case .saving: return tr("저장", "Saving")
        case .access: return tr("접근 권한", "Access")
        case .menuIcon: return tr("메뉴바 아이콘", "Menu bar icon")
        }
    }

    // 무채색 얇은 선 아이콘
    var icon: String {
        switch self {
        case .general: return "gearshape"
        case .stamp: return "calendar"
        case .caption: return "textformat"
        case .saving: return "folder"
        case .access: return "hand.raised"
        case .menuIcon: return "menubar.rectangle"
        }
    }

    // 상단에 미리보기를 고정할 탭
    var showsPreview: Bool { self == .stamp || self == .caption }
}

final class SettingsUIState: ObservableObject {
    @Published var tab: SettingsTab = .general
}

let settingsUI = SettingsUIState()

// 자리 고르기: 사진 틀 안의 7곳 중 하나를 눌러서 선택
struct PlacementPicker: View {
    @Binding var selection: WatermarkPosition
    let aspect: Double

    var body: some View {
        let frameH: CGFloat = 62
        let frameW = frameH * CGFloat(max(1.0, aspect))
        VStack(spacing: 0) {
            HStack(spacing: 0) { slot(.topLeft); slot(.topCenter); slot(.topRight) }
            HStack(spacing: 0) { Color.clear; slot(.center); Color.clear }
            HStack(spacing: 0) { slot(.bottomLeft); slot(.bottomCenter); slot(.bottomRight) }
        }
        .padding(5)
        .frame(width: frameW, height: frameH)
        .background(RoundedRectangle(cornerRadius: 6).fill(Color.primary.opacity(0.04)))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.secondary.opacity(0.4), lineWidth: 1))
    }

    private func slot(_ p: WatermarkPosition) -> some View {
        let on = selection == p
        let align: Alignment
        switch p {
        case .topLeft, .bottomLeft: align = .leading
        case .topRight, .bottomRight: align = .trailing
        default: align = .center
        }
        return Button { selection = p } label: {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(on ? Color.accentColor : Color.secondary.opacity(0.35))
                .frame(width: 18, height: on ? 5 : 4)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: align)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(p.title)
    }
}

// 설정 창 미리보기: 카메라 실시간 화면 위에 실제 사진과 같은 위치로 표시
struct SettingsPreview: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var camera: CameraModel
    var height: CGFloat = 150

    var body: some View {
        let h = height
        let s = settings.style
        ZStack {
            LinearGradient(colors: [Color(white: 0.55), Color(white: 0.28)],
                           startPoint: .top, endPoint: .bottom)
            if camera.cameraState == .running {
                CameraPreview(camera: camera)
            }
            TimelineView(.periodic(from: Date(), by: 1)) { tl in
                WatermarkOverlay(style: s,
                                 bottom: s.bottomText(date: tl.date, place: camera.placeName ?? "Seoul"),
                                 top: s.topText(settings.topText, enabled: settings.topEnabled),
                                 height: h)
            }
        }
        .frame(width: h * CGFloat(settings.aspect.ratio), height: h)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var camera: CameraModel
    @ObservedObject var ui: SettingsUIState

    var body: some View {
        HStack(spacing: 0) {
            sidebar
                .frame(width: 190)
            Divider()
            // 내용이 제일 많은 '날짜·위치 표시' 화면 크기에 창을 딱 맞춤
            stampLayout
                .opacity(ui.tab == .stamp ? 1 : 0)
                .allowsHitTesting(ui.tab == .stamp)
                .overlay {
                    if ui.tab != .stamp {
                        otherTabs
                    }
                }
        }
        .frame(width: 780)
        .fixedSize(horizontal: false, vertical: true)
        .id(settings.language)      // 언어를 바꾸면 모든 문구·드롭다운을 새로 그림
    }

    private var otherTabs: some View {
        VStack(spacing: 0) {
            if ui.tab == .caption {
                SettingsPreview(settings: settings, camera: camera, height: 132)
                    .padding(.vertical, 12)
                Divider()
            }
            Form {
                switch ui.tab {
                case .general: generalTab
                case .stamp: EmptyView()
                case .caption: captionTab
                case .saving: savingTab
                case .access: accessTab
                case .menuIcon: menuIconTab
                }
            }
            .formStyle(.grouped)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: Sidebar (아이폰 설정 앱처럼 왼쪽 세로 목록)

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(SettingsTab.allCases) { tab in
                tabRow(tab)
            }
            Spacer()
            VStack(alignment: .leading, spacing: 2) {
                Text("GlaNce \(appVersion)")
                HStack(spacing: 3) {
                    Text("© 2026")
                    Link(copyrightOwner, destination: copyrightURL)
                        .help(copyrightURL.absoluteString)
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
        }
        .padding(10)
        .padding(.top, 8)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.primary.opacity(0.03))
    }

    private func tabRow(_ tab: SettingsTab) -> some View {
        let selected = ui.tab == tab
        return Button {
            ui.tab = tab
        } label: {
            HStack(spacing: 10) {
                Image(systemName: tab.icon)
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(selected ? Color.primary : Color.secondary)
                    .frame(width: 22)
                Text(tab.title)
                    .font(.system(size: 13, weight: selected ? .medium : .regular))
                    .foregroundStyle(Color.primary)
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(selected ? Color.primary.opacity(0.09) : Color.clear, in: RoundedRectangle(cornerRadius: 7))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: Tabs

    private var generalTab: some View {
        Section {
            Picker(tr("언어", "Language"), selection: $settings.language) {
                ForEach(AppLanguage.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            Toggle(tr("찍으면 바로 복사", "Copy after each shot"), isOn: $settings.copyToClipboard)
            Picker(tr("사진 비율", "Photo shape"), selection: $settings.aspect) {
                ForEach(AspectRatio.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            HStack {
                Text(tr("창 크기", "Window size")).frame(width: 80, alignment: .leading)
                Slider(value: popSizeBinding, in: 1...10, step: 1)
                Text("\(settings.popSize)")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .frame(width: 24, alignment: .trailing)
                Button(tr("기본", "Reset")) { settings.popSize = AppSettings.defaultPopSize }
            }
        } footer: {
            Text(tr("복사를 켜두면 찍은 사진을 바로 ⌘V로 붙여넣을 수 있어요. 창 크기는 팝업 오른쪽 아래 모서리를 끌어서도 바꿀 수 있어요.",
                    "With copy on, paste your shot anywhere with ⌘V. You can also resize by dragging the popup's bottom-right corner."))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // 2열로 묶고 여백을 줄여서 스크롤 없이 한 화면에 (이 화면 높이가 곧 설정 창 높이)
    private var stampLayout: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                SettingsPreview(settings: settings, camera: camera, height: 132)
                Spacer()
            }

            card {
                Grid(alignment: .leading, horizontalSpacing: 22, verticalSpacing: 7) {
                    GridRow {
                        toggleCell("photo", tr("사진에 넣기", "Add to photos"), $settings.wmEnabled)
                        toggleCell("eye", tr("카메라 화면에서도 보기", "Show while previewing"), $settings.livePreview)
                    }
                    Divider().gridCellColumns(2)
                    Group {
                        GridRow {
                            toggleCell("calendar", tr("날짜", "Date"), $settings.showDate)
                            cell("calendar.badge.clock", tr("모양", "Style")) {
                                PopUpPicker(titles: plainTitles(DateStyle.allCases.map { $0.title }),
                                            selectedIndex: indexBinding(DateStyle.allCases, \.dateStyle)).fixedSize()
                            }
                            .disabled(!settings.showDate || settings.style.isRetro)
                        }
                        GridRow {
                            toggleCell("clock", tr("시간", "Time"), $settings.showTime)
                            cell("123.rectangle", tr("표기", "Format")) {
                                PopUpPicker(titles: plainTitles(TimeStyle.allCases.map { $0.title }),
                                            selectedIndex: indexBinding(TimeStyle.allCases, \.timeStyle)).fixedSize()
                            }
                            .disabled(!settings.showTime)
                        }
                        GridRow {
                            toggleCell("building.2", tr("도시 이름", "City"), $settings.showPlace)
                                .disabled(settings.style.isRetro)
                            cell("safari", tr("지금 위치", "Now")) {
                                Text(camera.placeName ?? tr("확인 중…", "Checking…"))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                Button { camera.refreshPlace() } label: {
                                    Image(systemName: "arrow.clockwise")
                                }
                                .buttonStyle(.borderless)
                                .help(tr("위치 새로고침", "Refresh location"))
                            }
                        }
                        GridRow {
                            toggleCell("textformat", tr("영문 대문자로", "ALL CAPS"), $settings.uppercase)
                            cell("character", tr("글꼴", "Font")) {
                                PopUpPicker(titles: fontTitles, selectedIndex: indexBinding(WatermarkFont.allCases, \.wmFont)).fixedSize()
                            }
                            .disabled(settings.style.isRetro)
                        }
                    }
                    .disabled(!settings.wmEnabled)
                }
            }

            card {
                Grid(alignment: .leading, horizontalSpacing: 22, verticalSpacing: 7) {
                    GridRow(alignment: .top) {
                        VStack(alignment: .leading, spacing: 7) {
                            cell("paintpalette", tr("색", "Color")) {
                                PopUpPicker(titles: colorTitles, selectedIndex: indexBinding(WatermarkColor.allCases, \.wmColor)).fixedSize()
                            }
                            // 자리: 사진 틀 모양에서 바로 고르기
                            HStack(alignment: .top, spacing: 8) {
                                cellIcon("square.grid.3x3")
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(tr("자리", "Placement"))
                                    Text(settings.position.title)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 6)
                                PlacementPicker(selection: $settings.position, aspect: settings.aspect.ratio)
                            }
                        }
                        VStack(spacing: 7) {
                            sliderCell("textformat.size", tr("크기", "Size"), $settings.sizePct, 1.5...8, step: 0.1, format: "%.1f")
                            sliderCell("circle.lefthalf.filled", tr("진하기", "Opacity"), $settings.opacity, 20...100, step: 1, format: "%.0f%%")
                            sliderCell("arrow.left.and.right", tr("글자 간격", "Spacing"), $settings.kernPct, 0...50, step: 1, format: "%.0f")
                        }
                    }
                }
            }
            .disabled(!settings.wmEnabled)

            // 레트로 안내 자리는 항상 비워둬서 창 높이가 출렁이지 않게
            HStack {
                Text(settings.style.isRetro
                     ? tr("레트로 주황은 필름 카메라처럼 날짜만 찍혀요 (글꼴 자동)",
                          "Retro orange stamps only the date, like film (auto font)")
                     : " ")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer()
                Button(tr("기본값으로", "Reset")) { settings.resetWatermark() }
                    .controlSize(.small)
            }
            .padding(.horizontal, 4)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .top)
    }

    // 설정 묶음 카드 (Form보다 여백이 적음)
    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.primary.opacity(0.045)))
    }

    private var captionTab: some View {
        Section {
            Grid(alignment: .leading, horizontalSpacing: 22, verticalSpacing: 12) {
                GridRow {
                    toggleCell("textformat", tr("상단 문구 쓰기", "Use caption"), $settings.topEnabled)
                    sliderCell("textformat.size", tr("크기", "Size"), $settings.topSizePct, 1.5...8, step: 0.1, format: "%.1f")
                        .disabled(!settings.topEnabled)
                }
                GridRow {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            cellIcon("character.cursor.ibeam")
                            TextField(tr("문구", "Caption"), text: $settings.topText)
                                .textFieldStyle(.roundedBorder)
                        }
                        Text(tr("한 줄, 최대 40자", "One line, up to 40 characters"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 26)
                    }
                    .gridCellColumns(2)
                    .disabled(!settings.topEnabled)
                }
            }
        } footer: {
            HStack(alignment: .top) {
                Text(tr("팝업 왼쪽 위 버튼으로도 바로 입력할 수 있어요. 비워두면 표시되지 않고, 글꼴과 색은 날짜·위치 표시 설정을 따라요.",
                        "You can also type it from the button at the popup's top left. Leave it empty to hide it. Font and color follow the date & place settings."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(tr("기본값으로", "Reset")) { settings.resetCaption() }
                    .controlSize(.small)
            }
        }
    }

    // MARK: Compact cells (아이콘 + 이름 + 조절)

    private func cellIcon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 13, weight: .light))
            .foregroundStyle(.secondary)
            .frame(width: 18)
    }

    private func cell<Content: View>(_ icon: String, _ title: String,
                                     @ViewBuilder trailing: () -> Content) -> some View {
        HStack(spacing: 8) {
            cellIcon(icon)
            Text(title).lineLimit(1)
            Spacer(minLength: 6)
            trailing()
        }
        .frame(maxWidth: .infinity)
    }

    private func toggleCell(_ icon: String, _ title: String, _ isOn: Binding<Bool>) -> some View {
        cell(icon, title) {
            Toggle("", isOn: isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.small)
        }
    }

    private func sliderCell(_ icon: String, _ title: String, _ value: Binding<Double>, _ range: ClosedRange<Double>,
                            step: Double, format: String) -> some View {
        HStack(spacing: 8) {
            cellIcon(icon)
            Text(title).lineLimit(1).frame(width: 64, alignment: .leading)
            Slider(value: value, in: range, step: step)
                .controlSize(.small)
            Text(String(format: format, value.wrappedValue))
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(width: 38, alignment: .trailing)
        }
        .frame(maxWidth: .infinity)
    }

    private var savingTab: some View {
        Section {
            LabeledContent(tr("저장 위치", "Save to")) {
                Text(settings.saveDirDisplay)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Spacer()
                Button(tr("열기", "Open")) { settings.openSaveDir() }
                Button(tr("기본 위치", "Default")) { settings.resetSaveDir() }
                    .disabled(settings.saveDir == AppSettings.defaultDir)
                Button(tr("변경…", "Change…")) { settings.chooseSaveDir() }
            }
        }
    }

    private var accessTab: some View {
        Section {
            HStack {
                Text(tr("카메라", "Camera"))
                Spacer()
                Text(cameraAuthText).foregroundStyle(.secondary)
                Button(tr("설정 열기", "Open settings")) { openPrivacySettings("Privacy_Camera") }
            }
            HStack {
                Text(tr("위치", "Location"))
                Spacer()
                Text(locationAuthText).foregroundStyle(.secondary)
                Button(tr("설정 열기", "Open settings")) { openPrivacySettings("Privacy_LocationServices") }
            }
        } footer: {
            Text(tr("위치를 꺼두면 사진에 날짜만 들어가요.", "With location off, only the date is added."))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var menuIconTab: some View {
        Section {
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                GridRow {
                    ForEach(Array(MenuIcon.allCases.prefix(5))) { icon in iconTile(icon) }
                }
                GridRow {
                    ForEach(Array(MenuIcon.allCases.dropFirst(5))) { icon in iconTile(icon) }
                }
            }
        }
    }

    // MARK: Helpers

    private var popSizeBinding: Binding<Double> {
        Binding(get: { Double(settings.popSize) },
                set: { settings.popSize = min(10, max(1, Int($0.rounded()))) })
    }

    // 목록에서 현재 값의 위치 ↔ 설정 값 연결
    private func indexBinding<T: Equatable>(_ all: [T], _ key: ReferenceWritableKeyPath<AppSettings, T>) -> Binding<Int> {
        Binding(get: { all.firstIndex(of: settings[keyPath: key]) ?? 0 },
                set: { i in if i >= 0 && i < all.count { settings[keyPath: key] = all[i] } })
    }

    private func plainTitles(_ names: [String]) -> [NSAttributedString] {
        names.map { NSAttributedString(string: $0, attributes: [.font: NSFont.systemFont(ofSize: 13)]) }
    }

    private var fontTitles: [NSAttributedString] {
        WatermarkFont.allCases.map { f in
            NSAttributedString(string: f.menuTitle, attributes: [.font: f.font(size: 14)])
        }
    }

    private var colorTitles: [NSAttributedString] {
        WatermarkColor.allCases.map { c in
            let dot = NSMutableAttributedString(
                string: c == .white ? "◯  " : "●  ",
                attributes: [.foregroundColor: c == .white ? NSColor.secondaryLabelColor : c.swatch,
                             .font: NSFont.systemFont(ofSize: 13)])
            let nameFont = c == .retro
                ? NSFont.monospacedSystemFont(ofSize: 13, weight: .semibold)
                : NSFont.systemFont(ofSize: 13)
            dot.append(NSAttributedString(string: c.title, attributes: [.font: nameFont]))
            return dot
        }
    }

    private var cameraAuthText: String {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return tr("허용됨", "Allowed")
        case .notDetermined: return tr("아직 안 물어봄", "Not asked yet")
        default: return tr("꺼져 있음", "Off")
        }
    }

    private var locationAuthText: String {
        switch camera.locationAuth {
        case .authorizedAlways, .authorized: return tr("허용됨", "Allowed")
        case .notDetermined: return tr("아직 안 물어봄", "Not asked yet")
        default: return tr("꺼져 있음", "Off")
        }
    }

    private func sliderRow(_ title: String, _ value: Binding<Double>, _ range: ClosedRange<Double>,
                           step: Double, format: String) -> some View {
        HStack {
            Text(title).frame(width: 80, alignment: .leading)
            Slider(value: value, in: range, step: step)
            Text(String(format: format, value.wrappedValue))
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(width: 44, alignment: .trailing)
        }
    }

    private func iconTile(_ icon: MenuIcon) -> some View {
        let selected = settings.menuIcon == icon
        return Button {
            settings.menuIcon = icon
        } label: {
            Image(nsImage: icon.image())
                .renderingMode(.template)
                .foregroundStyle(.primary)
                .frame(width: 28, height: 22)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selected ? Color.accentColor.opacity(0.18) : Color.clear,
                            in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(selected ? Color.accentColor : Color.secondary.opacity(0.25), lineWidth: 1))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(icon.title)
    }
}

// macOS 창 모서리와 같은 대각선 크기 조절 커서 (없으면 십자 커서)
func diagonalResizeCursor() -> NSCursor {
    if #available(macOS 15.0, *) {
        return NSCursor.frameResize(position: .bottomRight, directions: .all)
    }
    let sel = NSSelectorFromString("_windowResizeNorthWestSouthEastCursor")
    if class_getClassMethod(NSCursor.self, sel) != nil,
       let c = NSCursor.perform(sel)?.takeUnretainedValue() as? NSCursor {
        return c
    }
    return .crosshair
}

// 시스템 설정 > 개인정보 보호 및 보안의 해당 항목 열기
func openPrivacySettings(_ anchor: String) {
    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?\(anchor)") {
        NSWorkspace.shared.open(url)
    }
}

// MARK: - Menu bar icons (템플릿 이미지라 다크/라이트 모드 자동 대응)

func symbolIcon(_ name: String) -> NSImage {
    let cfg = NSImage.SymbolConfiguration(pointSize: 15, weight: .regular)
    guard let img = NSImage(systemSymbolName: name, accessibilityDescription: "GlaNce")?
            .withSymbolConfiguration(cfg) else { return makeReflectedGIcon() }
    img.isTemplate = true
    return img
}

func makeReflectedGIcon() -> NSImage {
    let size = NSSize(width: 22, height: 18)
    let img = NSImage(size: size, flipped: false) { rect in
        guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
        let cx = rect.midX

        // 거울 축
        NSColor.black.withAlphaComponent(0.4).setFill()
        NSBezierPath(rect: NSRect(x: cx - 0.5, y: 1.5, width: 1, height: 15)).fill()

        // 메뉴바 크기에선 Ultra Light가 너무 얇아서 Regular 사용
        let font = NSFont(name: "AvenirNext-Regular", size: 15) ?? NSFont.systemFont(ofSize: 15)
        func line(_ alpha: CGFloat) -> CTLine {
            let s = NSAttributedString(string: "g", attributes: [
                .font: font,
                NSAttributedString.Key(kCTForegroundColorAttributeName as String):
                    NSColor.black.withAlphaComponent(alpha).cgColor
            ])
            return CTLineCreateWithAttributedString(s)
        }
        let solid = line(1.0)
        let faint = line(0.45)
        let b = CTLineGetImageBounds(solid, ctx)
        let x = cx - 1.5 - (b.origin.x + b.width)
        let y = rect.midY - (b.origin.y + b.height / 2)

        ctx.textPosition = CGPoint(x: x, y: y)
        CTLineDraw(solid, ctx)

        ctx.saveGState()
        ctx.translateBy(x: 2 * cx, y: 0)
        ctx.scaleBy(x: -1, y: 1)
        ctx.textPosition = CGPoint(x: x, y: y)
        CTLineDraw(faint, ctx)
        ctx.restoreGState()
        return true
    }
    img.isTemplate = true
    img.accessibilityDescription = "GlaNce"
    return img
}

func makeHandMirrorIcon() -> NSImage {
    let img = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { _ in
        NSColor.black.set()
        // 거울면
        let glass = NSBezierPath(ovalIn: NSRect(x: 3.8, y: 6.2, width: 10.4, height: 11))
        glass.lineWidth = 1.6
        glass.stroke()
        // 반사광
        let shine = NSBezierPath()
        shine.move(to: NSPoint(x: 6.6, y: 12.4))
        shine.line(to: NSPoint(x: 8.4, y: 14.6))
        shine.lineWidth = 1.2
        shine.lineCapStyle = .round
        shine.stroke()
        // 손잡이
        NSBezierPath(roundedRect: NSRect(x: 8.1, y: 0.6, width: 1.8, height: 6.0),
                     xRadius: 0.9, yRadius: 0.9).fill()
        return true
    }
    img.isTemplate = true
    img.accessibilityDescription = "GlaNce"
    return img
}

// MARK: - Menu bar item + popover

final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate, NSWindowDelegate {
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()
    private var settingsWindow: NSWindow?
    private var settingsHoldsCamera = false
    private var subs = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(togglePopover)
        }

        popover.behavior = .transient          // 바깥 클릭하면 닫힘 (분리된 창은 유지)
        popover.animates = true                // 말풍선처럼 커지며 나타나는 기본 애니메이션
        popover.delegate = self
        let host = NSHostingController(
            rootView: GlaNceView(
                camera: sharedCamera,
                settings: settings,
                ui: popoverUI,
                openSettings: { [weak self] in self?.openSettings() }
            )
        )
        // 비율·크기를 바꾸면 팝업이 SwiftUI 화면 크기를 그대로 따라가도록 (여백/잘림 방지)
        host.sizingOptions = [.preferredContentSize]
        popover.contentViewController = host

        // 설정에서 아이콘을 바꾸면 바로 반영
        settings.$menuIcon
            .sink { [weak self] icon in self?.statusItem.button?.image = icon.image() }
            .store(in: &subs)

        // 언어 변경 시 설정 창 제목 갱신 (값이 바뀐 뒤에 읽도록 한 박자 늦춤)
        settings.$language
            .sink { [weak self] _ in
                DispatchQueue.main.async { self?.settingsWindow?.title = tr("GlaNce 설정", "GlaNce Settings") }
            }
            .store(in: &subs)

        // 첫 실행 때 권한 창이 바로 뜨도록
        NSApp.activate(ignoringOtherApps: true)
        sharedCamera.requestPermissionsOnLaunch()
    }

    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    func openSettings() {
        // 설정 창 미리보기에서도 카메라를 쓰니까, 팝업을 닫기 전에 먼저 잡아둠
        if !settingsHoldsCamera {
            sharedCamera.acquire()
            settingsHoldsCamera = true
        }
        if popover.isShown && !popover.isDetached { popover.performClose(nil) }
        if settingsWindow == nil {
            let w = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 780, height: 560),
                             styleMask: [.titled, .closable, .miniaturizable],
                             backing: .buffered, defer: false)
            w.title = tr("GlaNce 설정", "GlaNce Settings")
            w.isReleasedWhenClosed = false
            w.delegate = self
            let host = NSHostingController(rootView: SettingsView(settings: settings, camera: sharedCamera, ui: settingsUI))
            host.sizingOptions = [.preferredContentSize]   // 창 크기 = 화면 내용 크기
            w.contentViewController = host
            w.center()
            settingsWindow = w
        }
        sharedCamera.refreshPlace()
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
    }

    // 설정 창을 닫으면 카메라 놓기
    func windowWillClose(_ notification: Notification) {
        guard (notification.object as? NSWindow) === settingsWindow, settingsHoldsCamera else { return }
        settingsHoldsCamera = false
        sharedCamera.release()
    }

    // 팝오버가 보이는 동안 카메라 사용
    func popoverWillShow(_ notification: Notification) {
        popoverUI.editingTop = false
        sharedCamera.acquire()
    }

    func popoverDidClose(_ notification: Notification) {
        popoverUI.editingTop = false
        sharedCamera.cancelCountdown()
        sharedCamera.release()
    }

    // 팝오버를 잡고 끌어내리면 떠 있는 창으로 분리
    func popoverShouldDetach(_ popover: NSPopover) -> Bool { true }

    func popoverDidDetach(_ popover: NSPopover) {
        popover.contentViewController?.view.window?.level = .floating
    }
}

@main
enum GlaNceMain {
    static let delegate = AppDelegate()

    static func main() {
        let app = NSApplication.shared
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}
