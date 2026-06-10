import SwiftUI

// MARK: - Flick data types

enum FlickDirection { case center, up, right, down, left }

struct FlickChars {
    let center: String
    let left: String?
    let up: String?
    let right: String?
    let down: String?

    init(_ center: String, left: String? = nil, up: String? = nil,
         right: String? = nil, down: String? = nil) {
        self.center = center; self.left = left; self.up = up
        self.right = right; self.down = down
    }

    func char(for dir: FlickDirection) -> String? {
        switch dir {
        case .center: return center
        case .left:   return left
        case .up:     return up
        case .right:  return right
        case .down:   return down
        }
    }
}

// MARK: - Themes

enum KeyboardTheme: String, CaseIterable {
    case system, terminal, neon, sakura, midnight, paper, sunset

    var next: KeyboardTheme {
        let all = Self.allCases
        return all[(all.firstIndex(of: self)! + 1) % all.count]
    }

    var icon: String {
        switch self {
        case .system:   return "Aa"
        case .terminal: return ">_"
        case .neon:     return "◈"
        case .sakura:   return "❀"
        case .midnight: return "☾"
        case .paper:    return "▢"
        case .sunset:   return "◐"
        }
    }
}

struct ThemeConfig {
    let keyBg: Color
    let keyActiveBg: Color
    let keyFg: Color
    let keyFlickFg: Color
    let keyRadius: CGFloat
    let funcBg: Color
    let funcFg: Color
    let calloutBg: Color
    let calloutFg: Color
    let calloutFlickFg: Color
    let calloutRadius: CGFloat
    let calloutShadowColor: Color
    let calloutShadowRadius: CGFloat
    let calloutFont: Font
}

extension ThemeConfig {
    static let system = ThemeConfig(
        keyBg: Color(UIColor.systemBackground),
        keyActiveBg: Color(UIColor.systemGray4),
        keyFg: Color(UIColor.label),
        keyFlickFg: .accentColor,
        keyRadius: 6,
        funcBg: Color(UIColor.systemGray3),
        funcFg: Color(UIColor.label),
        calloutBg: Color(UIColor.systemBackground),
        calloutFg: Color(UIColor.label),
        calloutFlickFg: .accentColor,
        calloutRadius: 8,
        calloutShadowColor: .black.opacity(0.35),
        calloutShadowRadius: 4,
        calloutFont: .system(size: 28, weight: .semibold)
    )

    static let terminal = ThemeConfig(
        keyBg: Color(red: 0.07, green: 0.07, blue: 0.07),
        keyActiveBg: Color(red: 0.0, green: 0.28, blue: 0.0),
        keyFg: Color(red: 0.0, green: 0.9, blue: 0.2),
        keyFlickFg: Color(red: 1.0, green: 0.85, blue: 0.0),
        keyRadius: 2,
        funcBg: Color(red: 0.04, green: 0.04, blue: 0.04),
        funcFg: Color(red: 0.0, green: 0.75, blue: 0.15),
        calloutBg: Color(red: 0.04, green: 0.07, blue: 0.04),
        calloutFg: Color(red: 0.0, green: 0.9, blue: 0.2),
        calloutFlickFg: Color(red: 1.0, green: 0.85, blue: 0.0),
        calloutRadius: 2,
        calloutShadowColor: Color(red: 0.0, green: 0.8, blue: 0.0).opacity(0.55),
        calloutShadowRadius: 8,
        calloutFont: .system(size: 26, weight: .bold, design: .monospaced)
    )

    static let neon = ThemeConfig(
        keyBg: Color(red: 0.06, green: 0.06, blue: 0.14),
        keyActiveBg: Color(red: 0.22, green: 0.0, blue: 0.38),
        keyFg: Color(red: 0.72, green: 0.72, blue: 1.0),
        keyFlickFg: Color(red: 0.0, green: 1.0, blue: 1.0),
        keyRadius: 4,
        funcBg: Color(red: 0.04, green: 0.04, blue: 0.10),
        funcFg: Color(red: 0.65, green: 0.65, blue: 0.95),
        calloutBg: Color(red: 0.06, green: 0.06, blue: 0.18),
        calloutFg: Color(red: 0.0, green: 1.0, blue: 1.0),
        calloutFlickFg: Color(red: 1.0, green: 0.0, blue: 1.0),
        calloutRadius: 5,
        calloutShadowColor: Color.cyan.opacity(0.7),
        calloutShadowRadius: 10,
        calloutFont: .system(size: 28, weight: .bold)
    )

    static let sakura = ThemeConfig(
        keyBg: Color(red: 1.0, green: 0.97, blue: 0.98),
        keyActiveBg: Color(red: 0.98, green: 0.85, blue: 0.90),
        keyFg: Color(red: 0.35, green: 0.20, blue: 0.25),
        keyFlickFg: Color(red: 0.85, green: 0.20, blue: 0.40),
        keyRadius: 10,
        funcBg: Color(red: 0.95, green: 0.88, blue: 0.91),
        funcFg: Color(red: 0.35, green: 0.20, blue: 0.25),
        calloutBg: Color(red: 1.0, green: 0.97, blue: 0.98),
        calloutFg: Color(red: 0.35, green: 0.20, blue: 0.25),
        calloutFlickFg: Color(red: 0.85, green: 0.20, blue: 0.40),
        calloutRadius: 12,
        calloutShadowColor: Color(red: 0.85, green: 0.40, blue: 0.55).opacity(0.3),
        calloutShadowRadius: 5,
        calloutFont: .system(size: 28, weight: .semibold)
    )

    static let midnight = ThemeConfig(
        keyBg: Color(red: 0.09, green: 0.13, blue: 0.22),
        keyActiveBg: Color(red: 0.16, green: 0.22, blue: 0.38),
        keyFg: Color(red: 0.75, green: 0.84, blue: 0.98),
        keyFlickFg: Color(red: 0.55, green: 0.88, blue: 1.0),
        keyRadius: 6,
        funcBg: Color(red: 0.05, green: 0.08, blue: 0.14),
        funcFg: Color(red: 0.60, green: 0.72, blue: 0.90),
        calloutBg: Color(red: 0.09, green: 0.13, blue: 0.24),
        calloutFg: Color(red: 0.75, green: 0.84, blue: 0.98),
        calloutFlickFg: Color(red: 0.55, green: 0.88, blue: 1.0),
        calloutRadius: 8,
        calloutShadowColor: Color(red: 0.3, green: 0.5, blue: 0.9).opacity(0.4),
        calloutShadowRadius: 6,
        calloutFont: .system(size: 28, weight: .semibold)
    )

    static let paper = ThemeConfig(
        keyBg: Color(red: 0.99, green: 0.98, blue: 0.96),
        keyActiveBg: Color(red: 0.90, green: 0.87, blue: 0.82),
        keyFg: Color(red: 0.12, green: 0.12, blue: 0.11),
        keyFlickFg: Color(red: 0.30, green: 0.20, blue: 0.10),
        keyRadius: 2,
        funcBg: Color(red: 0.88, green: 0.86, blue: 0.83),
        funcFg: Color(red: 0.12, green: 0.12, blue: 0.11),
        calloutBg: Color(red: 0.99, green: 0.98, blue: 0.96),
        calloutFg: Color(red: 0.12, green: 0.12, blue: 0.11),
        calloutFlickFg: Color(red: 0.30, green: 0.20, blue: 0.10),
        calloutRadius: 2,
        calloutShadowColor: .black.opacity(0.20),
        calloutShadowRadius: 3,
        calloutFont: .system(size: 28, weight: .semibold)
    )

    static let sunset = ThemeConfig(
        keyBg: Color(red: 0.22, green: 0.12, blue: 0.13),
        keyActiveBg: Color(red: 0.38, green: 0.20, blue: 0.18),
        keyFg: Color(red: 1.0, green: 0.84, blue: 0.70),
        keyFlickFg: Color(red: 1.0, green: 0.55, blue: 0.20),
        keyRadius: 5,
        funcBg: Color(red: 0.12, green: 0.06, blue: 0.07),
        funcFg: Color(red: 0.90, green: 0.70, blue: 0.55),
        calloutBg: Color(red: 0.24, green: 0.13, blue: 0.14),
        calloutFg: Color(red: 1.0, green: 0.84, blue: 0.70),
        calloutFlickFg: Color(red: 1.0, green: 0.55, blue: 0.20),
        calloutRadius: 5,
        calloutShadowColor: Color(red: 1.0, green: 0.45, blue: 0.10).opacity(0.45),
        calloutShadowRadius: 7,
        calloutFont: .system(size: 28, weight: .semibold)
    )

    static func config(for theme: KeyboardTheme) -> ThemeConfig {
        switch theme {
        case .system:   return .system
        case .terminal: return .terminal
        case .neon:     return .neon
        case .sakura:   return .sakura
        case .midnight: return .midnight
        case .paper:    return .paper
        case .sunset:   return .sunset
        }
    }
}

private struct KbThemeKey: EnvironmentKey {
    static var defaultValue = ThemeConfig.system
}
extension EnvironmentValues {
    var kbTheme: ThemeConfig {
        get { self[KbThemeKey.self] }
        set { self[KbThemeKey.self] = newValue }
    }
}

// MARK: - Callout shape (rounded rect + directional triangle)

private struct CalloutShape: Shape {
    enum Side { case top, bottom, left, right }
    var side: Side
    var triLen: CGFloat = 7
    var triBase: CGFloat = 14
    var cr: CGFloat = 8

    func path(in rect: CGRect) -> Path {
        var p = Path()
        switch side {
        case .bottom:
            let bH = rect.height - triLen
            p.move(to: .init(x: rect.minX + cr, y: rect.minY))
            p.addLine(to: .init(x: rect.maxX - cr, y: rect.minY))
            p.addArc(center: .init(x: rect.maxX - cr, y: rect.minY + cr), radius: cr, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
            p.addLine(to: .init(x: rect.maxX, y: bH - cr))
            p.addArc(center: .init(x: rect.maxX - cr, y: bH - cr), radius: cr, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
            p.addLine(to: .init(x: rect.midX + triBase/2, y: bH))
            p.addLine(to: .init(x: rect.midX, y: rect.maxY))
            p.addLine(to: .init(x: rect.midX - triBase/2, y: bH))
            p.addLine(to: .init(x: rect.minX + cr, y: bH))
            p.addArc(center: .init(x: rect.minX + cr, y: bH - cr), radius: cr, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            p.addLine(to: .init(x: rect.minX, y: rect.minY + cr))
            p.addArc(center: .init(x: rect.minX + cr, y: rect.minY + cr), radius: cr, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        case .top:
            let bY = triLen
            p.move(to: .init(x: rect.midX - triBase/2, y: bY))
            p.addLine(to: .init(x: rect.midX, y: rect.minY))
            p.addLine(to: .init(x: rect.midX + triBase/2, y: bY))
            p.addLine(to: .init(x: rect.maxX - cr, y: bY))
            p.addArc(center: .init(x: rect.maxX - cr, y: bY + cr), radius: cr, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
            p.addLine(to: .init(x: rect.maxX, y: rect.maxY - cr))
            p.addArc(center: .init(x: rect.maxX - cr, y: rect.maxY - cr), radius: cr, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
            p.addLine(to: .init(x: rect.minX + cr, y: rect.maxY))
            p.addArc(center: .init(x: rect.minX + cr, y: rect.maxY - cr), radius: cr, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            p.addLine(to: .init(x: rect.minX, y: bY + cr))
            p.addArc(center: .init(x: rect.minX + cr, y: bY + cr), radius: cr, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        case .right:
            let bW = rect.width - triLen
            p.move(to: .init(x: rect.minX + cr, y: rect.minY))
            p.addLine(to: .init(x: bW - cr, y: rect.minY))
            p.addArc(center: .init(x: bW - cr, y: rect.minY + cr), radius: cr, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
            p.addLine(to: .init(x: bW, y: rect.midY - triBase/2))
            p.addLine(to: .init(x: rect.maxX, y: rect.midY))
            p.addLine(to: .init(x: bW, y: rect.midY + triBase/2))
            p.addLine(to: .init(x: bW, y: rect.maxY - cr))
            p.addArc(center: .init(x: bW - cr, y: rect.maxY - cr), radius: cr, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
            p.addLine(to: .init(x: rect.minX + cr, y: rect.maxY))
            p.addArc(center: .init(x: rect.minX + cr, y: rect.maxY - cr), radius: cr, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            p.addLine(to: .init(x: rect.minX, y: rect.minY + cr))
            p.addArc(center: .init(x: rect.minX + cr, y: rect.minY + cr), radius: cr, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        case .left:
            let bX = triLen
            p.move(to: .init(x: bX + cr, y: rect.minY))
            p.addLine(to: .init(x: rect.maxX - cr, y: rect.minY))
            p.addArc(center: .init(x: rect.maxX - cr, y: rect.minY + cr), radius: cr, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
            p.addLine(to: .init(x: rect.maxX, y: rect.maxY - cr))
            p.addArc(center: .init(x: rect.maxX - cr, y: rect.maxY - cr), radius: cr, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
            p.addLine(to: .init(x: bX + cr, y: rect.maxY))
            p.addArc(center: .init(x: bX + cr, y: rect.maxY - cr), radius: cr, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
            p.addLine(to: .init(x: bX, y: rect.midY + triBase/2))
            p.addLine(to: .init(x: rect.minX, y: rect.midY))
            p.addLine(to: .init(x: bX, y: rect.midY - triBase/2))
            p.addLine(to: .init(x: bX, y: rect.minY + cr))
            p.addArc(center: .init(x: bX + cr, y: rect.minY + cr), radius: cr, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        }
        p.closeSubpath()
        return p
    }
}

// MARK: - Callout preference (lifts callout above all keyboard elements)

private struct FlickCalloutData {
    let chars: FlickChars
    let dir: FlickDirection
    let isFlicking: Bool
    let anchor: Anchor<CGRect>
}

private struct FlickCalloutKey: PreferenceKey {
    static var defaultValue: FlickCalloutData? = nil
    static func reduce(value: inout FlickCalloutData?, nextValue: () -> FlickCalloutData?) {
        value = nextValue() ?? value
    }
}

private struct FlickCalloutView: View {
    let data: FlickCalloutData
    let keyRect: CGRect
    let bounds: CGSize
    @Environment(\.kbTheme) var theme

    private var size: CGSize {
        switch data.dir {
        case .center, .up, .down: return CGSize(width: 52, height: 61)
        case .left, .right:       return CGSize(width: 61, height: 50)
        }
    }

    private var side: CalloutShape.Side {
        switch data.dir {
        case .center, .up: return .bottom
        case .down:        return .top
        case .left:        return .right
        case .right:       return .left
        }
    }

    private var textOffset: CGSize {
        let t: CGFloat = 3.5
        switch data.dir {
        case .center, .up: return CGSize(width: 0, height: -t)
        case .down:        return CGSize(width: 0, height:  t)
        case .left:        return CGSize(width: -t, height: 0)
        case .right:       return CGSize(width:  t, height: 0)
        }
    }

    private var center: CGPoint {
        let s = size
        var c: CGPoint
        switch data.dir {
        case .center, .up:
            c = CGPoint(x: keyRect.midX, y: keyRect.minY - s.height / 2)
        case .down:
            c = CGPoint(x: keyRect.midX, y: keyRect.maxY + s.height / 2)
        case .left:
            c = CGPoint(x: keyRect.minX - s.width / 2, y: keyRect.midY)
        case .right:
            c = CGPoint(x: keyRect.maxX + s.width / 2, y: keyRect.midY)
        }
        // キーボード拡張はビュー領域外に描画できないため、はみ出す分を内側に寄せる
        c.x = min(max(s.width / 2 + 1, c.x), bounds.width - s.width / 2 - 1)
        c.y = min(max(s.height / 2 + 1, c.y), bounds.height - s.height / 2 - 1)
        return c
    }

    var body: some View {
        let s = size
        ZStack {
            CalloutShape(side: side, cr: theme.calloutRadius)
                .fill(theme.calloutBg)
                .shadow(color: theme.calloutShadowColor,
                        radius: theme.calloutShadowRadius, x: 0, y: 2)
            Text(data.chars.char(for: data.dir) ?? data.chars.center)
                .font(theme.calloutFont)
                .foregroundColor(data.isFlicking ? theme.calloutFlickFg : theme.calloutFg)
                .offset(x: textOffset.width, y: textOffset.height)
        }
        .frame(width: s.width, height: s.height)
        .position(center)
    }
}

// MARK: - FlickKey

struct FlickKey: View {
    let chars: FlickChars
    let onSelect: (String) -> Void

    @Environment(\.kbTheme) var theme
    @State private var dir: FlickDirection = .center
    @State private var isActive = false
    @State private var isFlicking = false
    private let threshold: CGFloat = 22

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: theme.keyRadius)
                .fill(isActive ? theme.keyActiveBg : theme.keyBg)
                .shadow(color: .black.opacity(0.3), radius: 0, x: 0, y: 1)

            if isFlicking {
                Text(chars.char(for: dir) ?? chars.center)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(theme.keyFlickFg)
            } else {
                Text(chars.center)
                    .font(.system(size: 18))
                    .foregroundColor(theme.keyFg)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { v in
                    isActive = true
                    let dx = v.translation.width, dy = v.translation.height
                    let dist = sqrt(dx * dx + dy * dy)
                    if dist >= threshold {
                        isFlicking = true
                        if abs(dx) > abs(dy) { dir = dx > 0 ? .right : .left }
                        else { dir = dy < 0 ? .up : .down }
                    } else {
                        isFlicking = false; dir = .center
                    }
                }
                .onEnded { v in
                    let dx = v.translation.width, dy = v.translation.height
                    let dist = sqrt(dx * dx + dy * dy)
                    let finalDir: FlickDirection
                    if dist < threshold { finalDir = .center }
                    else if abs(dx) > abs(dy) { finalDir = dx > 0 ? .right : .left }
                    else { finalDir = dy < 0 ? .up : .down }
                    onSelect(chars.char(for: finalDir) ?? chars.center)
                    isActive = false; isFlicking = false; dir = .center
                }
        )
        .anchorPreference(key: FlickCalloutKey.self, value: .bounds) { anchor in
            isActive ? FlickCalloutData(chars: chars, dir: dir, isFlicking: isFlicking, anchor: anchor) : nil
        }
    }
}

// MARK: - FlickKeyboardView

struct FlickKeyboardView: View {
    let onInsert: (String) -> Void
    let onBackspace: () -> Void
    let onBackspaceSlide: (Int) -> Void
    let onReturn: () -> Void
    let onSwitchToEnglish: () -> Void
    let onNextKeyboard: () -> Void
    let getContextBefore: () -> String
    let onSetMarkedText: (String) -> Void
    let onUnmarkText: () -> Void

    @State private var slideCount = 0
    @State private var contextBefore = ""
    @State private var composingText = ""
    @State private var candidates: [String] = []
    @State private var isNumberMode = false
    @State private var currentTheme: KeyboardTheme = {
        let ud = UserDefaults(suiteName: "group.com.bigk4huna.swipedelete") ?? .standard
        return KeyboardTheme(rawValue: ud.string(forKey: "kbTheme") ?? "") ?? .system
    }()

    private var theme: ThemeConfig { ThemeConfig.config(for: currentTheme) }

    private let kanaGrid: [[FlickChars]] = [
        [FlickChars("あ", left:"い", up:"う", right:"え", down:"お"),
         FlickChars("か", left:"き", up:"く", right:"け", down:"こ"),
         FlickChars("さ", left:"し", up:"す", right:"せ", down:"そ")],
        [FlickChars("た", left:"ち", up:"つ", right:"て", down:"と"),
         FlickChars("な", left:"に", up:"ぬ", right:"ね", down:"の"),
         FlickChars("は", left:"ひ", up:"ふ", right:"へ", down:"ほ")],
        [FlickChars("ま", left:"み", up:"む", right:"め", down:"も"),
         FlickChars("や", left:"ゃ", up:"ゆ", right:"ー", down:"よ"),
         FlickChars("ら", left:"り", up:"る", right:"れ", down:"ろ")],
        [FlickChars("゛", up:"小"),
         FlickChars("わ", left:"を", up:"ん", right:"ー", down:"〜"),
         FlickChars("、", left:"。", up:"？", right:"！", down:"…")],
    ]

    private let numberGrid: [[FlickChars]] = [
        [FlickChars("1", left:"！", up:"☆", right:"♪", down:"♡"),
         FlickChars("2", left:"？", up:"…", right:"〜", down:"・"),
         FlickChars("3", left:"「", up:"」", right:"『", down:"』")],
        [FlickChars("4", left:"￥", up:"$", right:"€", down:"£"),
         FlickChars("5", left:"%", up:"#", right:"&", down:"@"),
         FlickChars("6", left:"＋", up:"−", right:"×", down:"÷")],
        [FlickChars("7", left:"（", up:"）", right:"〔", down:"〕"),
         FlickChars("8", left:"「", up:"」", right:"【", down:"】"),
         FlickChars("9", left:"《", up:"》", right:"〈", down:"〉")],
        [FlickChars(".", left:",", up:":", right:";", down:"…"),
         FlickChars("0", left:"-", up:"〜", right:"ー", down:"_"),
         FlickChars("@", left:"#", up:"*", right:"/", down:"~")],
    ]

    private var currentGrid: [[FlickChars]] { isNumberMode ? numberGrid : kanaGrid }

    private let smallOnlyCycle: [Character: Character] = [
        "あ":"ぁ","ぁ":"あ","い":"ぃ","ぃ":"い","う":"ぅ","ぅ":"う",
        "え":"ぇ","ぇ":"え","お":"ぉ","ぉ":"お",
        "つ":"っ","っ":"つ","づ":"っ",
        "や":"ゃ","ゃ":"や","ゆ":"ゅ","ゅ":"ゆ","よ":"ょ","ょ":"よ","わ":"ゎ","ゎ":"わ",
    ]

    private let modifierCycle: [Character: Character] = {
        var m: [Character: Character] = [:]
        let cycles: [[Character]] = [
            ["か","が"],["き","ぎ"],["く","ぐ"],["け","げ"],["こ","ご"],
            ["さ","ざ"],["し","じ"],["す","ず"],["せ","ぜ"],["そ","ぞ"],
            ["た","だ"],["ち","ぢ"],["て","で"],["と","ど"],
            ["つ","っ","づ"],
            ["は","ば","ぱ"],["ひ","び","ぴ"],["ふ","ぶ","ぷ"],
            ["へ","べ","ぺ"],["ほ","ぼ","ぽ"],
            ["あ","ぁ"],["い","ぃ"],["う","ぅ"],["え","ぇ"],["お","ぉ"],
            ["や","ゃ"],["ゆ","ゅ"],["よ","ょ"],["わ","ゎ"],
        ]
        for cycle in cycles {
            for (i, ch) in cycle.enumerated() { m[ch] = cycle[(i + 1) % cycle.count] }
        }
        return m
    }()

    private let keySize: CGFloat = 44
    private let sp: CGFloat = 3

    var body: some View {
        VStack(spacing: 0) {
            topBar
            HStack(alignment: .top, spacing: sp) {
                leftColumn
                kanaColumn(0)
                kanaColumn(1)
                kanaColumn(2)
                rightColumn
            }
            .padding(.horizontal, sp)
            .padding(.top, sp)
            .padding(.bottom, 3)
        }
        .environment(\.kbTheme, theme)
        .onChange(of: composingText) { newText in
            if newText.isEmpty {
                candidates = []
                onUnmarkText()
            } else {
                candidates = KanjiConverter.shared.candidates(for: newText)
                onSetMarkedText(newText)
            }
        }
        .onChange(of: slideCount) { newCount in
            if newCount > 0 {
                let before = getContextBefore()
                contextBefore = (!composingText.isEmpty && !before.hasSuffix(composingText))
                    ? before + composingText
                    : before
            }
        }
        .overlayPreferenceValue(FlickCalloutKey.self) { data in
            if let data = data {
                GeometryReader { proxy in
                    FlickCalloutView(data: data, keyRect: proxy[data.anchor], bounds: proxy.size)
                }
                .allowsHitTesting(false)
            }
        }
    }

    // MARK: - Columns

    private var leftColumn: some View {
        VStack(spacing: sp) {
            switchKey.frame(maxWidth: .infinity, minHeight: keySize, maxHeight: keySize)
            globeKey.frame(maxWidth: .infinity, minHeight: keySize, maxHeight: keySize)
            numberToggleKey.frame(maxWidth: .infinity, minHeight: keySize, maxHeight: keySize)
            themeToggleKey.frame(maxWidth: .infinity, minHeight: keySize, maxHeight: keySize)
        }
        .frame(maxWidth: .infinity)
    }

    private var rightColumn: some View {
        VStack(spacing: sp) {
            backspaceKey.frame(maxWidth: .infinity, minHeight: keySize, maxHeight: keySize)
            spaceKey.frame(maxWidth: .infinity, minHeight: keySize, maxHeight: keySize)
            returnKey.frame(maxWidth: .infinity, minHeight: keySize * 2 + sp, maxHeight: keySize * 2 + sp)
        }
        .frame(maxWidth: .infinity)
    }

    private func kanaColumn(_ col: Int) -> some View {
        VStack(spacing: sp) {
            ForEach(0..<currentGrid.count, id: \.self) { row in
                let chars = currentGrid[row][col]
                FlickKey(chars: chars) { char in
                    handleSelect(char, fromKey: chars)
                }
                .frame(maxWidth: .infinity, minHeight: keySize, maxHeight: keySize)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Top bar

    @ViewBuilder
    private var topBar: some View {
        if slideCount > 0 {
            deletionPreview
        } else if !candidates.isEmpty {
            candidateBar
        } else {
            Color.clear.frame(height: 36)
        }
    }

    private var candidateBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                if !composingText.isEmpty {
                    Text(composingText)
                        .font(.system(size: 15))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .padding(.leading, 4)
                }
                ForEach(candidates, id: \.self) { candidate in
                    Button(action: {
                        onInsert(candidate)
                        composingText = ""
                        candidates = []
                    }) {
                        Text(candidate)
                            .font(.system(size: 17))
                            .foregroundColor(Color(UIColor.label))
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 6)
        }
        .frame(height: 36)
    }

    private var deletionPreview: some View {
        let all = Array(contextBefore)
        let del = min(slideCount, all.count)
        let window = Array(all.suffix(28))
        let keepCount = max(0, window.count - del)
        let keep = String(window.prefix(keepCount))
        let deleted = String(window.suffix(min(del, window.count)))

        return HStack(spacing: 0) {
            Spacer(minLength: 8)
            HStack(spacing: 0) {
                Text(keep).foregroundColor(Color(UIColor.label))
                Text(deleted).foregroundColor(.white).background(Color.red)
                Text("｜").foregroundColor(Color(UIColor.label))
            }
            .font(.system(size: 15)).lineLimit(1)
            .padding(.horizontal, 10).padding(.vertical, 3)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(6)
            Spacer(minLength: 8)
        }
        .frame(height: 36)
    }

    // MARK: - Function keys

    private var backspaceKey: some View {
        BackspaceKey(
            slideCount: $slideCount,
            cornerRadius: theme.keyRadius,
            iconSize: 17,
            onTap: {
                if !composingText.isEmpty {
                    composingText = String(composingText.dropLast())
                } else { onBackspace() }
            },
            onSlideDelete: { count in
                if !composingText.isEmpty {
                    if count <= composingText.count {
                        composingText = String(composingText.dropLast(count))
                    } else {
                        onUnmarkText()
                        composingText = ""; candidates = []
                        onBackspaceSlide(count)
                    }
                } else {
                    onBackspaceSlide(count)
                }
            }
        )
    }

    private var spaceKey: some View {
        Button(action: { onInsert("　") }) {
            RoundedRectangle(cornerRadius: theme.keyRadius)
                .fill(theme.keyBg)
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
                .overlay(Text("空白").font(.system(size: 13)).foregroundColor(theme.keyFg))
        }
        .buttonStyle(.plain)
    }

    private var returnKey: some View {
        Button(action: {
            if !composingText.isEmpty {
                onInsert(composingText); composingText = ""; candidates = []
            } else { onReturn() }
        }) {
            RoundedRectangle(cornerRadius: theme.keyRadius)
                .fill(theme.funcBg)
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
                .overlay(
                    Text(composingText.isEmpty ? "改行" : "確定")
                        .font(.system(size: 15))
                        .foregroundColor(theme.funcFg)
                )
        }
        .buttonStyle(.plain)
    }

    private var switchKey: some View {
        Button(action: { commitComposing(); onSwitchToEnglish() }) {
            RoundedRectangle(cornerRadius: theme.keyRadius)
                .fill(theme.funcBg)
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
                .overlay(
                    Text("ABC")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(theme.funcFg)
                )
        }
        .buttonStyle(.plain)
    }

    private var globeKey: some View {
        Button(action: { commitComposing(); onNextKeyboard() }) {
            RoundedRectangle(cornerRadius: theme.keyRadius)
                .fill(theme.funcBg)
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
                .overlay(Image(systemName: "globe").font(.system(size: 16)).foregroundColor(theme.funcFg))
        }
        .buttonStyle(.plain)
    }

    private var numberToggleKey: some View {
        Button(action: { commitComposing(); isNumberMode.toggle() }) {
            RoundedRectangle(cornerRadius: theme.keyRadius)
                .fill(isNumberMode ? theme.keyFlickFg.opacity(0.25) : theme.funcBg)
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
                .overlay(
                    Text(isNumberMode ? "かな" : "☆123")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(theme.funcFg)
                )
        }
        .buttonStyle(.plain)
    }

    private var themeToggleKey: some View {
        Button(action: {
            currentTheme = currentTheme.next
            let ud = UserDefaults(suiteName: "group.com.bigk4huna.swipedelete") ?? .standard
            ud.set(currentTheme.rawValue, forKey: "kbTheme")
        }) {
            RoundedRectangle(cornerRadius: theme.keyRadius)
                .fill(theme.funcBg)
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
                .overlay(
                    Text(currentTheme.icon)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(theme.keyFg)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Input handling

    private let composablePunctuation: Set<String> = ["〜", "、", "。", "？", "！", "…"]

    private func isHiragana(_ str: String) -> Bool {
        guard let s = str.unicodeScalars.first else { return false }
        return s.value >= 0x3041 && s.value <= 0x3096
    }

    private func commitComposing() {
        guard !composingText.isEmpty else { return }
        onInsert(composingText)
        composingText = ""
        candidates = []
    }

    private func handleSelect(_ char: String, fromKey chars: FlickChars) {
        if isNumberMode {
            commitComposing()
            onInsert(char)
            return
        }
        if chars.center == "゛" {
            if char == "小" { applyModifier(smallOnlyCycle) }
            else { applyModifier(modifierCycle) }
        } else if isHiragana(char) || char == "ー" || composablePunctuation.contains(char) {
            composingText += char
        } else {
            commitComposing()
            onInsert(char)
        }
    }

    @discardableResult
    private func applyModifier(_ cycle: [Character: Character]) -> Bool {
        if !composingText.isEmpty {
            guard let last = composingText.last, let next = cycle[last] else { return false }
            composingText = String(composingText.dropLast()) + String(next)
            return true
        } else {
            guard let last = getContextBefore().last, let next = cycle[last] else { return false }
            onBackspace(); onInsert(String(next))
            return true
        }
    }
}
