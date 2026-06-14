import UIKit

// =====================================================================
// SwipeDelete Keyboard — キーボード拡張本体 (UIKit)
//
// ・配置/挙動は iOS 純正12キー(フリック)に準拠
//     左列:  ⤺ / ☆123 / ABC / 🌐   右列: ⌫ / 空白 / 改行(2行分)
//     かな:  あかさ / たなは / まやら / 小゛゜ わ 、。?!
// ・かな漢字変換: AzooKey (KanjiConverter) + 上部候補バー
//     - 候補をタップした時だけ変換結果で確定
//     - それ以外(記号入力・モード切替・改行=確定)は無変換ひらがなのまま確定
//     - ー 〜 、。?! … は composing に追加され確定を起こさない
// ・独自機能: ⌫ を押したまま左へスライド → 削除範囲を選んで一括削除
// ・追加の便利機能:
//     - 空白キーを左右にスライドでカーソル移動
//     - ⌫ 長押しで連続削除(加速つき)
//     - 小゛゜キーで 小文字/濁点/半濁点 をタップ循環 (composing対応)
//     - ⤺ で直前の入力/削除を取り消し (変換中は未確定文字のクリア)
// ・テーマ7種。⤺ キーを長押しでキーボード内からも切替可能
// =====================================================================

// MARK: - テーマ

struct ThemePalette {
    let background: UIColor       // キーボード全体の背景
    let keyBg: UIColor            // 文字キー
    let keyText: UIColor
    let specialBg: UIColor        // 機能キー(⌫, モード切替など)
    let specialText: UIColor
    let returnBg: UIColor         // 改行キー(アクセント)
    let returnText: UIColor
    let popupBg: UIColor          // フリックガイド/削除プレビュー/候補
    let popupText: UIColor
    let popupHighlight: UIColor
    let cornerRadius: CGFloat
    let usesMonospaced: Bool
    let glowColor: UIColor?       // nil なら通常のドロップシャドウ

    func keyFont(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        usesMonospaced
            ? .monospacedSystemFont(ofSize: size, weight: weight)
            : .systemFont(ofSize: size, weight: weight)
    }
}

enum KeyboardTheme: String, CaseIterable {
    case system, terminal, neon, sakura, midnight, paper, sunset

    static let storageKey = "kbTheme"
    static let suiteName  = "group.com.bigk4huna.swipedelete"

    // App Group未設定の環境ではsuiteNameへの書き込みが永続化されないため、
    // standardにも常に書く。読み出しはsuite優先(App Group設定後にアプリ側の変更が勝つ)
    static func load() -> KeyboardTheme {
        let raw = UserDefaults(suiteName: suiteName)?.string(forKey: storageKey)
            ?? UserDefaults.standard.string(forKey: storageKey)
            ?? ""
        return KeyboardTheme(rawValue: raw) ?? .system
    }

    func save() {
        UserDefaults(suiteName: KeyboardTheme.suiteName)?.set(rawValue, forKey: KeyboardTheme.storageKey)
        UserDefaults.standard.set(rawValue, forKey: KeyboardTheme.storageKey)
    }

    var next: KeyboardTheme {
        let all = KeyboardTheme.allCases
        let i = all.firstIndex(of: self) ?? 0
        return all[(i + 1) % all.count]
    }

    var displayName: String {
        switch self {
        case .system:   return "System"
        case .terminal: return "Terminal"
        case .neon:     return "Neon"
        case .sakura:   return "Sakura"
        case .midnight: return "Midnight"
        case .paper:    return "Paper"
        case .sunset:   return "Sunset"
        }
    }

    func palette(darkMode: Bool) -> ThemePalette {
        func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> UIColor {
            UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
        }
        switch self {
        case .system:
            // 純正そっくり (ライト/ダーク自動追従)
            return darkMode
            ? ThemePalette(background: rgb(43, 43, 43), keyBg: rgb(107, 107, 107),
                           keyText: .white, specialBg: rgb(70, 70, 70), specialText: .white,
                           returnBg: rgb(70, 70, 70), returnText: .white,
                           popupBg: rgb(107, 107, 107), popupText: .white,
                           popupHighlight: rgb(10, 132, 255),
                           cornerRadius: 5, usesMonospaced: false, glowColor: nil)
            : ThemePalette(background: rgb(210, 213, 219), keyBg: .white,
                           keyText: .black, specialBg: rgb(172, 177, 185), specialText: .black,
                           returnBg: rgb(172, 177, 185), returnText: .black,
                           popupBg: .white, popupText: .black,
                           popupHighlight: rgb(0, 122, 255),
                           cornerRadius: 5, usesMonospaced: false, glowColor: nil)
        case .terminal:
            return ThemePalette(background: rgb(10, 12, 10), keyBg: rgb(22, 28, 22),
                                keyText: rgb(0, 230, 70), specialBg: rgb(16, 20, 16),
                                specialText: rgb(0, 170, 50),
                                returnBg: rgb(0, 90, 30), returnText: rgb(180, 255, 200),
                                popupBg: rgb(14, 18, 14), popupText: rgb(0, 230, 70),
                                popupHighlight: rgb(0, 255, 100),
                                cornerRadius: 3, usesMonospaced: true, glowColor: rgb(0, 230, 70, 0.5))
        case .neon:
            return ThemePalette(background: rgb(15, 13, 35), keyBg: rgb(30, 26, 60),
                                keyText: rgb(0, 245, 255), specialBg: rgb(24, 20, 50),
                                specialText: rgb(255, 70, 200),
                                returnBg: rgb(255, 40, 160), returnText: .white,
                                popupBg: rgb(26, 22, 55), popupText: rgb(0, 245, 255),
                                popupHighlight: rgb(255, 70, 200),
                                cornerRadius: 9, usesMonospaced: false, glowColor: rgb(0, 245, 255, 0.55))
        case .sakura:
            return ThemePalette(background: rgb(252, 238, 242), keyBg: .white,
                                keyText: rgb(90, 50, 65), specialBg: rgb(246, 210, 222),
                                specialText: rgb(150, 70, 100),
                                returnBg: rgb(232, 110, 150), returnText: .white,
                                popupBg: .white, popupText: rgb(90, 50, 65),
                                popupHighlight: rgb(232, 110, 150),
                                cornerRadius: 12, usesMonospaced: false, glowColor: nil)
        case .midnight:
            return ThemePalette(background: rgb(10, 16, 30), keyBg: rgb(24, 34, 56),
                                keyText: rgb(190, 215, 250), specialBg: rgb(17, 25, 43),
                                specialText: rgb(120, 150, 200),
                                returnBg: rgb(60, 110, 220), returnText: .white,
                                popupBg: rgb(24, 34, 56), popupText: rgb(190, 215, 250),
                                popupHighlight: rgb(110, 170, 255),
                                cornerRadius: 7, usesMonospaced: false, glowColor: nil)
        case .paper:
            return ThemePalette(background: rgb(244, 242, 236), keyBg: rgb(252, 251, 248),
                                keyText: rgb(30, 30, 28), specialBg: rgb(230, 227, 218),
                                specialText: rgb(90, 88, 82),
                                returnBg: rgb(40, 40, 38), returnText: rgb(250, 249, 245),
                                popupBg: rgb(252, 251, 248), popupText: rgb(30, 30, 28),
                                popupHighlight: rgb(40, 40, 38),
                                cornerRadius: 4, usesMonospaced: false, glowColor: nil)
        case .sunset:
            return ThemePalette(background: rgb(35, 18, 24), keyBg: rgb(60, 32, 38),
                                keyText: rgb(255, 215, 180), specialBg: rgb(48, 25, 31),
                                specialText: rgb(245, 150, 100),
                                returnBg: rgb(240, 100, 60), returnText: .white,
                                popupBg: rgb(55, 30, 36), popupText: rgb(255, 215, 180),
                                popupHighlight: rgb(255, 140, 80),
                                cornerRadius: 9, usesMonospaced: false, glowColor: nil)
        }
    }
}

// MARK: - キー定義

enum FlickDirection: Int, CaseIterable { case center, left, up, right, down }

struct FlickMap {
    let center: String
    let left: String?
    let up: String?
    let right: String?
    let down: String?

    func value(_ d: FlickDirection) -> String? {
        switch d {
        case .center: return center
        case .left:   return left
        case .up:     return up
        case .right:  return right
        case .down:   return down
        }
    }
}

enum KeyAction {
    case input(FlickMap)
    case smallDakuten          // 小゛゜
    case backspace
    case space
    case newline
    case modeKana
    case modeABC
    case modeQWERTY
    case mode123
    case modeQwertyNum   // QWERTY→数字記号ページ
    case modeQwertySym   // 数字→追加記号ページ
    case globe
    case undo
    case shift
}

enum KeyboardMode { case kana, abc, number, qwerty, qwertyNumber, qwertySymbol }

// MARK: - 入力マップ(純正準拠)

private let kanaKeys: [[FlickMap]] = [
    [FlickMap(center: "あ", left: "い", up: "う", right: "え", down: "お"),
     FlickMap(center: "か", left: "き", up: "く", right: "け", down: "こ"),
     FlickMap(center: "さ", left: "し", up: "す", right: "せ", down: "そ")],
    [FlickMap(center: "た", left: "ち", up: "つ", right: "て", down: "と"),
     FlickMap(center: "な", left: "に", up: "ぬ", right: "ね", down: "の"),
     FlickMap(center: "は", left: "ひ", up: "ふ", right: "へ", down: "ほ")],
    [FlickMap(center: "ま", left: "み", up: "む", right: "め", down: "も"),
     FlickMap(center: "や", left: "（", up: "ゆ", right: "）", down: "よ"),
     FlickMap(center: "ら", left: "り", up: "る", right: "れ", down: "ろ")],
    // 4段目: [小゛゜] [わ] [、。?!] — 小゛゜は専用アクション
    [FlickMap(center: "わ", left: "を", up: "ん", right: "ー", down: "〜"),
     FlickMap(center: "、", left: "。", up: "？", right: "！", down: "…")]
]

private let abcKeys: [[FlickMap]] = [
    [FlickMap(center: "@", left: "#", up: "/", right: "&", down: "_"),
     FlickMap(center: "a", left: "b", up: "c", right: nil, down: nil),
     FlickMap(center: "d", left: "e", up: "f", right: nil, down: nil)],
    [FlickMap(center: "g", left: "h", up: "i", right: nil, down: nil),
     FlickMap(center: "j", left: "k", up: "l", right: nil, down: nil),
     FlickMap(center: "m", left: "n", up: "o", right: nil, down: nil)],
    [FlickMap(center: "p", left: "q", up: "r", right: "s", down: nil),
     FlickMap(center: "t", left: "u", up: "v", right: nil, down: nil),
     FlickMap(center: "w", left: "x", up: "y", right: "z", down: nil)],
    [FlickMap(center: "'", left: "\"", up: "(", right: ")", down: nil),
     FlickMap(center: ".", left: ",", up: "?", right: "!", down: "…")]
]

private let numberKeys: [[FlickMap]] = [
    [FlickMap(center: "1", left: "☆", up: "♪", right: "→", down: nil),
     FlickMap(center: "2", left: "¥", up: "$", right: "€", down: nil),
     FlickMap(center: "3", left: "%", up: "°", right: "#", down: nil)],
    [FlickMap(center: "4", left: "○", up: "*", right: "・", down: nil),
     FlickMap(center: "5", left: "+", up: "×", right: "÷", down: nil),
     FlickMap(center: "6", left: "<", up: "=", right: ">", down: nil)],
    [FlickMap(center: "7", left: "「", up: "」", right: ":", down: nil),
     FlickMap(center: "8", left: "〒", up: "々", right: "〆", down: nil),
     FlickMap(center: "9", left: "^", up: "|", right: "\\", down: nil)],
    [FlickMap(center: "(", left: ")", up: "[", right: "]", down: nil),
     FlickMap(center: "0", left: "〜", up: "…", right: nil, down: nil),
     FlickMap(center: ".", left: ",", up: "-", right: "/", down: nil)]
]

// 小゛゜のタップ循環テーブル(小文字→濁点→半濁点の順)
private let dakutenCycles: [[String]] = [
    ["つ", "っ", "づ"], ["う", "ぅ", "ゔ"], ["は", "ば", "ぱ"], ["ひ", "び", "ぴ"],
    ["ふ", "ぶ", "ぷ"], ["へ", "べ", "ぺ"], ["ほ", "ぼ", "ぽ"],
    ["あ", "ぁ"], ["い", "ぃ"], ["え", "ぇ"], ["お", "ぉ"],
    ["か", "が"], ["き", "ぎ"], ["く", "ぐ"], ["け", "げ"], ["こ", "ご"],
    ["さ", "ざ"], ["し", "じ"], ["す", "ず"], ["せ", "ぜ"], ["そ", "ぞ"],
    ["た", "だ"], ["ち", "ぢ"], ["て", "で"], ["と", "ど"],
    ["や", "ゃ"], ["ゆ", "ゅ"], ["よ", "ょ"], ["わ", "ゎ"]
]

private func dakutenNext(for ch: String) -> String? {
    for cycle in dakutenCycles {
        if let i = cycle.firstIndex(of: ch) {
            return cycle[(i + 1) % cycle.count]
        }
    }
    return nil
}

// MARK: - 取り消し用の操作記録

private enum EditOp {
    case inserted(String)
    case deleted(String)   // 削除されたテキスト(再挿入で取り消し)
}

// MARK: - キービュー

final class KeyView: UIControl {
    let action: KeyAction
    let titleLabel = UILabel()
    let hintLabel = UILabel()          // フリック候補のミニ表示 (例: いうえお)
    var isAccent = false               // 改行キー
    var isSpecial = false              // 機能キー

    init(action: KeyAction) {
        self.action = action
        super.init(frame: .zero)
        // タッチはVC側のtouchesBeganでヒットテストする(UIControlに呑ませない)
        // 地球儀キーだけはhandleInputModeList用にconfigureで有効化する
        isUserInteractionEnabled = false
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        hintLabel.textAlignment = .center
        hintLabel.adjustsFontSizeToFitWidth = true
        hintLabel.minimumScaleFactor = 0.4
        addSubview(titleLabel)
        addSubview(hintLabel)
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 0.5
        layer.shadowOpacity = 0.3
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        if hintLabel.text?.isEmpty == false {
            titleLabel.frame = CGRect(x: 0, y: 2, width: bounds.width, height: bounds.height * 0.62)
            hintLabel.frame = CGRect(x: 2, y: bounds.height * 0.62, width: bounds.width - 4, height: bounds.height * 0.32)
        } else {
            titleLabel.frame = bounds
        }
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }

    func apply(_ p: ThemePalette) {
        layer.cornerRadius = p.cornerRadius
        if isAccent {
            backgroundColor = p.returnBg
            titleLabel.textColor = p.returnText
        } else if isSpecial {
            backgroundColor = p.specialBg
            titleLabel.textColor = p.specialText
        } else {
            backgroundColor = p.keyBg
            titleLabel.textColor = p.keyText
        }
        hintLabel.textColor = titleLabel.textColor.withAlphaComponent(0.45)
        hintLabel.font = p.keyFont(size: 9)
        if let glow = p.glowColor, !isSpecial {
            layer.shadowColor = glow.cgColor
            layer.shadowRadius = 5
            layer.shadowOpacity = 0.8
            layer.shadowOffset = .zero
        } else {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowRadius = 0.5
            layer.shadowOpacity = 0.3
            layer.shadowOffset = CGSize(width: 0, height: 1)
        }
    }

    func setPressed(_ pressed: Bool) {
        alpha = pressed ? 0.6 : 1.0
    }
}

// MARK: - フリックガイド(十字ポップアップ)

final class FlickGuideView: UIView {
    private var labels: [FlickDirection: UILabel] = [:]
    private var bubbles: [FlickDirection: UIView] = [:]
    private let cell: CGFloat = 46

    init(map: FlickMap, palette: ThemePalette) {
        super.init(frame: CGRect(x: 0, y: 0, width: cell * 3, height: cell * 3))
        isUserInteractionEnabled = false
        for d in FlickDirection.allCases {
            guard let v = map.value(d) else { continue }
            let bubble = UIView()
            bubble.backgroundColor = palette.popupBg
            bubble.layer.cornerRadius = palette.cornerRadius + 2
            bubble.layer.shadowColor = UIColor.black.cgColor
            bubble.layer.shadowOpacity = 0.35
            bubble.layer.shadowRadius = 4
            bubble.layer.shadowOffset = CGSize(width: 0, height: 2)
            let lb = UILabel()
            lb.text = v
            lb.textAlignment = .center
            lb.font = palette.keyFont(size: 22, weight: .medium)
            lb.textColor = palette.popupText
            bubble.frame = frame(for: d)
            lb.frame = bubble.bounds
            bubble.addSubview(lb)
            addSubview(bubble)
            labels[d] = lb
            bubbles[d] = bubble
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    private func frame(for d: FlickDirection) -> CGRect {
        let s = cell
        switch d {
        case .center: return CGRect(x: s, y: s, width: s, height: s)
        case .left:   return CGRect(x: 0, y: s, width: s, height: s)
        case .up:     return CGRect(x: s, y: 0, width: s, height: s)
        case .right:  return CGRect(x: s * 2, y: s, width: s, height: s)
        case .down:   return CGRect(x: s, y: s * 2, width: s, height: s)
        }
    }

    func highlight(_ d: FlickDirection, palette: ThemePalette) {
        for (dir, bubble) in bubbles {
            let on = dir == d
            bubble.isHidden = (d != .center && !on)
            bubble.backgroundColor = on ? palette.popupHighlight : palette.popupBg
            labels[dir]?.textColor = on ? .white : palette.popupText
            bubble.transform = on ? CGAffineTransform(scaleX: 1.15, y: 1.15) : .identity
        }
    }
}

// MARK: - テーマピッカー

final class ThemePickerView: UIView {
    var onSelect: ((KeyboardTheme) -> Void)?

    init(current: KeyboardTheme, palette: ThemePalette, darkMode: Bool) {
        super.init(frame: .zero)
        backgroundColor = palette.background

        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.leadingAnchor.constraint(equalTo: leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: trailingAnchor),
            scroll.topAnchor.constraint(equalTo: topAnchor),
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 7
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -10),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 5),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -5),
            stack.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor, constant: -10),
        ])

        for theme in KeyboardTheme.allCases {
            let p = theme.palette(darkMode: darkMode)
            let btn = UIButton(type: .custom)
            btn.setTitle(theme.displayName, for: .normal)
            btn.setTitleColor(p.keyText, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            btn.backgroundColor = p.keyBg
            btn.layer.cornerRadius = p.cornerRadius + 1
            btn.contentEdgeInsets = UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10)
            // 選択中テーマはアクセントカラーの枠で強調
            btn.layer.borderWidth = (theme == current) ? 2.5 : 0
            btn.layer.borderColor = p.popupHighlight.cgColor
            btn.layer.shadowColor = UIColor.black.cgColor
            btn.layer.shadowOpacity = 0.25
            btn.layer.shadowRadius = 2
            btn.layer.shadowOffset = CGSize(width: 0, height: 1)
            btn.tag = KeyboardTheme.allCases.firstIndex(of: theme) ?? 0
            btn.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            // アクセントカラーを小さい丸で右上に表示
            let dot = UIView()
            dot.backgroundColor = p.returnBg
            dot.layer.cornerRadius = 4
            dot.translatesAutoresizingMaskIntoConstraints = false
            btn.addSubview(dot)
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 8),
                dot.heightAnchor.constraint(equalToConstant: 8),
                dot.topAnchor.constraint(equalTo: btn.topAnchor, constant: 4),
                dot.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -4),
            ])
            stack.addArrangedSubview(btn)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func tapped(_ sender: UIButton) {
        onSelect?(KeyboardTheme.allCases[sender.tag])
    }
}

// MARK: - メイン ViewController

final class KeyboardViewController: UIInputViewController {

    private var isJapaneseLayout = true

    private static func loadJapaneseLayout() -> Bool {
        if let v = UserDefaults(suiteName: KeyboardTheme.suiteName)?.object(forKey: "kbLayoutJapanese") as? Bool { return v }
        if let v = UserDefaults.standard.object(forKey: "kbLayoutJapanese") as? Bool { return v }
        return true
    }

    private var mode: KeyboardMode = .kana
    private var theme = KeyboardTheme.load()
    private var palette: ThemePalette {
        theme.palette(darkMode: traitCollection.userInterfaceStyle == .dark)
    }

    private var keys: [KeyView] = []
    private var heightConstraint: NSLayoutConstraint?

    // かな漢字変換
    private var composingText = ""
    private var candidates: [String] = []
    private let candidateBar = UIScrollView()
    private let candidateStack = UIStackView()
    private var topBarHeight: CGFloat { (isJapaneseLayout && mode == .kana) || mode == .qwerty ? 42 : 0 }
    private var isQwertyFamily: Bool { mode == .qwerty || mode == .qwertyNumber || mode == .qwertySymbol }

    // フリック状態
    private var activeKey: KeyView?
    private var touchStart: CGPoint = .zero
    private var currentDirection: FlickDirection = .center
    private var guideView: FlickGuideView?
    private let flickThreshold: CGFloat = 16

    // QWERTY シフト状態
    private var isShifted = false
    private let textChecker = UITextChecker()

    // バックスペース状態
    private var bsRepeatTimer: Timer?
    private var bsDeletedDuringHold = false
    private var bsRangeMode = false
    private var bsRangeCount = 0
    private var bsPreviewLabel: UILabel?
    private let bsRangeStep: CGFloat = 9   // 9pt ごとに1文字

    // 空白キーのカーソル移動
    private var spaceCursorMode = false
    private var spaceAccumulatedDX: CGFloat = 0
    private var spaceMoved = false

    // 取り消しスタック
    private var undoStack: [EditOp] = []

    // MARK: ライフサイクル

    override func viewDidLoad() {
        super.viewDidLoad()
        isJapaneseLayout = Self.loadJapaneseLayout()
        if !isJapaneseLayout { mode = .qwerty }
        setupCandidateBar()
        buildKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let newLayout = Self.loadJapaneseLayout()
        let layoutChanged = newLayout != isJapaneseLayout
        if layoutChanged {
            isJapaneseLayout = newLayout
            mode = isJapaneseLayout ? .kana : .qwerty
        }
        if heightConstraint == nil {
            let h = NSLayoutConstraint(item: view!, attribute: .height, relatedBy: .equal,
                                       toItem: nil, attribute: .notAnAttribute,
                                       multiplier: 1, constant: 236 + topBarHeight)
            h.priority = .init(999)
            view.addConstraint(h)
            heightConstraint = h
        } else if layoutChanged {
            heightConstraint?.constant = 236 + topBarHeight
        }
        // セッションをまたいだ composing は無効(marked textは保持されない)
        composingText = ""
        candidates = []
        reloadCandidateBar()
        theme = KeyboardTheme.load()   // 本体アプリでの変更を反映
        applyTheme()
        if layoutChanged { buildKeyboard() }
    }

    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        applyTheme()
    }

    // MARK: 構築

    private func buildKeyboard() {
        keys.forEach { $0.removeFromSuperview() }
        keys.removeAll()
        isShifted = false

        if isQwertyFamily {
            heightConstraint?.constant = 236 + topBarHeight
            buildQwertyKeys()
            return
        }

        heightConstraint?.constant = 236 + topBarHeight

        // 5列 × 4行 (改行は右列の3-4行を結合)
        var grid: [[KeyAction?]] = Array(repeating: Array(repeating: nil, count: 5), count: 4)

        // 左列(純正準拠): ⤺ / ☆123 / 英字/かな / 🌐 — モードにより表示が入れ替わる
        grid[0][0] = .undo
        switch mode {
        case .kana:
            grid[1][0] = .mode123
            grid[2][0] = .modeQWERTY          // ABC → QWERTYモードへ
        case .abc:
            grid[1][0] = .mode123
            grid[2][0] = isJapaneseLayout ? .modeKana : .modeQWERTY
        case .number:
            grid[1][0] = isJapaneseLayout ? .modeKana : .modeQWERTY
            grid[2][0] = isJapaneseLayout ? .modeABC : nil
        case .qwerty, .qwertyNumber, .qwertySymbol:
            break   // 上の早期リターンで処理済み
        }
        grid[3][0] = .globe

        // 中央 3列
        switch mode {
        case .kana:
            for r in 0..<3 {
                for c in 0..<3 { grid[r][c + 1] = .input(kanaKeys[r][c]) }
            }
            grid[3][1] = .smallDakuten
            grid[3][2] = .input(kanaKeys[3][0])   // わ
            grid[3][3] = .input(kanaKeys[3][1])   // 、。?!
        case .abc:
            for r in 0..<3 {
                for c in 0..<3 { grid[r][c + 1] = .input(abcKeys[r][c]) }
            }
            grid[3][1] = .smallDakuten            // a/A 大文字小文字トグルとして動作
            grid[3][2] = .input(abcKeys[3][0])
            grid[3][3] = .input(abcKeys[3][1])
        case .number:
            for r in 0..<4 {
                for c in 0..<3 { grid[r][c + 1] = .input(numberKeys[r][c]) }
            }
        case .qwerty, .qwertyNumber, .qwertySymbol:
            break   // 上の早期リターンで処理済み
        }

        // 右列: ⌫ / 空白 / 改行(結合)
        grid[0][4] = .backspace
        grid[1][4] = .space
        grid[2][4] = .newline   // 3-4行目を結合してレイアウト

        for r in 0..<4 {
            for c in 0..<5 {
                guard let action = grid[r][c] else { continue }
                let key = KeyView(action: action)
                configure(key, action: action)
                key.tag = r * 10 + c
                view.addSubview(key)
                keys.append(key)
            }
        }
        applyTheme()
        updateReturnKeyTitle()
        view.setNeedsLayout()
    }

    private func configure(_ key: KeyView, action: KeyAction) {
        switch action {
        case .input(let map):
            key.titleLabel.text = map.center
            let hints = [map.left, map.up, map.right].compactMap { $0 }
            // 数字/記号キーは候補ヒントをそのまま、かなは省略表示
            key.hintLabel.text = mode == .kana ? "" : hints.joined()
            if mode == .kana, map.center == "、" { key.titleLabel.text = "、。?!"; }
        case .smallDakuten:
            key.titleLabel.text = (mode == .kana) ? "小゛゜" : "a/A"
            key.isSpecial = false
        case .backspace:
            key.titleLabel.text = "⌫"; key.isSpecial = true
        case .space:
            key.titleLabel.text = (mode == .abc || isQwertyFamily || !isJapaneseLayout) ? "space" : "空白"
            key.isSpecial = true
        case .newline:
            key.titleLabel.text = (mode == .abc || isQwertyFamily || !isJapaneseLayout) ? "return" : "改行"
            key.isAccent = true
        case .modeKana:
            key.titleLabel.text = "あいう"; key.isSpecial = true
            key.isUserInteractionEnabled = true
            key.addTarget(self, action: #selector(modeKeyTapped(_:)), for: .touchUpInside)
            key.addTarget(self, action: #selector(modeKeyDown(_:)), for: .touchDown)
            key.addTarget(self, action: #selector(modeKeyUp(_:)), for: [.touchUpOutside, .touchCancel])
        case .modeABC:
            key.titleLabel.text = "abc"; key.isSpecial = true
            key.isUserInteractionEnabled = true
            key.addTarget(self, action: #selector(modeKeyTapped(_:)), for: .touchUpInside)
            key.addTarget(self, action: #selector(modeKeyDown(_:)), for: .touchDown)
            key.addTarget(self, action: #selector(modeKeyUp(_:)), for: [.touchUpOutside, .touchCancel])
        case .modeQWERTY:
            key.titleLabel.text = "ABC"; key.isSpecial = true
            key.isUserInteractionEnabled = true
            key.addTarget(self, action: #selector(modeKeyTapped(_:)), for: .touchUpInside)
            key.addTarget(self, action: #selector(modeKeyDown(_:)), for: .touchDown)
            key.addTarget(self, action: #selector(modeKeyUp(_:)), for: [.touchUpOutside, .touchCancel])
        case .shift:
            key.titleLabel.text = "⇧"; key.isSpecial = true
            key.isUserInteractionEnabled = true
            key.addTarget(self, action: #selector(shiftKeyTapped(_:)), for: .touchUpInside)
            key.addTarget(self, action: #selector(modeKeyDown(_:)), for: .touchDown)
            key.addTarget(self, action: #selector(modeKeyUp(_:)), for: [.touchUpOutside, .touchCancel])
        case .mode123:
            key.titleLabel.text = "☆123"; key.isSpecial = true
            key.isUserInteractionEnabled = true
            key.addTarget(self, action: #selector(modeKeyTapped(_:)), for: .touchUpInside)
            key.addTarget(self, action: #selector(modeKeyDown(_:)), for: .touchDown)
            key.addTarget(self, action: #selector(modeKeyUp(_:)), for: [.touchUpOutside, .touchCancel])
        case .globe:
            key.titleLabel.text = "◑"; key.isSpecial = true
            key.isUserInteractionEnabled = true
            key.addTarget(self, action: #selector(themeButtonTapped(_:)), for: .touchUpInside)
            key.addTarget(self, action: #selector(modeKeyDown(_:)), for: .touchDown)
            key.addTarget(self, action: #selector(modeKeyUp(_:)), for: [.touchUpOutside, .touchCancel])
        case .undo:
            key.titleLabel.text = "⤺"; key.isSpecial = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        candidateBar.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: topBarHeight)
        layoutKeys()
    }

    private func layoutKeys() {
        if isQwertyFamily { layoutQwertyKeys(); return }
        let m: CGFloat = 3                                  // キー間マージン
        let outerH: CGFloat = 3, outerV: CGFloat = 3
        let top = topBarHeight + outerV
        let w = view.bounds.width - outerH * 2
        let h = view.bounds.height - top - outerV
        guard w > 0, h > 0 else { return }
        let colW = (w - m * 4) / 5
        let rowH = (h - m * 3) / 4

        for key in keys {
            let r = key.tag / 10, c = key.tag % 10
            var f = CGRect(x: outerH + CGFloat(c) * (colW + m),
                           y: top + CGFloat(r) * (rowH + m),
                           width: colW, height: rowH)
            if case .newline = key.action {
                f.size.height = rowH * 2 + m               // 改行は2行分
            }
            key.frame = f
            let base = min(colW, rowH)
            switch key.action {
            case .input:
                key.titleLabel.font = palette.keyFont(size: base * 0.42, weight: .regular)
            case .space, .newline, .modeKana, .modeABC, .modeQWERTY, .mode123, .smallDakuten, .shift:
                key.titleLabel.font = palette.keyFont(size: base * 0.30, weight: .medium)
            default:
                key.titleLabel.font = palette.keyFont(size: base * 0.40, weight: .regular)
            }
        }
    }

    private func applyTheme() {
        let p = palette
        view.backgroundColor = p.background
        keys.forEach { $0.apply(p) }
        reloadCandidateBar()
    }

    // MARK: かな漢字変換

    private func setupCandidateBar() {
        candidateBar.showsHorizontalScrollIndicator = false
        view.addSubview(candidateBar)
        candidateStack.axis = .horizontal
        candidateStack.spacing = 6
        candidateStack.translatesAutoresizingMaskIntoConstraints = false
        candidateBar.addSubview(candidateStack)
        NSLayoutConstraint.activate([
            candidateStack.leadingAnchor.constraint(equalTo: candidateBar.contentLayoutGuide.leadingAnchor, constant: 8),
            candidateStack.trailingAnchor.constraint(equalTo: candidateBar.contentLayoutGuide.trailingAnchor, constant: -8),
            candidateStack.topAnchor.constraint(equalTo: candidateBar.contentLayoutGuide.topAnchor, constant: 6),
            candidateStack.bottomAnchor.constraint(equalTo: candidateBar.contentLayoutGuide.bottomAnchor, constant: -6),
            candidateStack.heightAnchor.constraint(equalTo: candidateBar.frameLayoutGuide.heightAnchor, constant: -12),
        ])
    }

    private func reloadCandidateBar() {
        candidateStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let p = palette
        for (i, cand) in candidates.enumerated() {
            let b = UIButton(type: .custom)
            b.setTitle(cand, for: .normal)
            b.setTitleColor(p.popupText, for: .normal)
            b.titleLabel?.font = p.keyFont(size: 16, weight: .medium)
            b.backgroundColor = p.popupBg
            b.layer.cornerRadius = p.cornerRadius + 1
            // 透過背景(システムブラー)の上でも読めるように軽い影をつける
            b.layer.shadowColor = UIColor.black.cgColor
            b.layer.shadowOpacity = 0.25
            b.layer.shadowRadius = 3
            b.layer.shadowOffset = CGSize(width: 0, height: 1)
            b.contentEdgeInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
            b.tag = i
            b.addTarget(self, action: #selector(candidateTapped(_:)), for: .touchUpInside)
            candidateStack.addArrangedSubview(b)
        }
        candidateBar.setContentOffset(.zero, animated: false)
    }

    @objc private func candidateTapped(_ sender: UIButton) {
        guard sender.tag < candidates.count else { return }
        let s = candidates[sender.tag]
        // insertTextはmarked text(composing表示)を置き換えて確定する
        textDocumentProxy.insertText(s)
        undoStack.append(.inserted(s)); trimUndo()
        composingText = ""
        candidates = []
        reloadCandidateBar()
        updateReturnKeyTitle()
        UIDevice.current.playInputClick()
    }

    /// composing 文字列を更新し marked text と候補バーに反映する
    private func setComposing(_ s: String) {
        composingText = s
        if s.isEmpty {
            // marked text を空に置き換えてから unmark = 未確定文字を捨てる
            textDocumentProxy.setMarkedText("", selectedRange: NSRange(location: 0, length: 0))
            textDocumentProxy.unmarkText()
            candidates = []
        } else {
            textDocumentProxy.setMarkedText(s, selectedRange: NSRange(location: s.utf16.count, length: 0))
            candidates = (mode == .qwerty) ? englishCandidates(for: s) : KanjiConverter.shared.candidates(for: s)
        }
        reloadCandidateBar()
        updateReturnKeyTitle()
    }

    /// UITextChecker を使って英語補完候補を生成する
    private func englishCandidates(for text: String) -> [String] {
        guard !text.isEmpty else { return [] }
        let range = NSRange(location: 0, length: (text as NSString).length)
        var results = textChecker.completions(forPartialWordRange: range, in: text, language: "en_US") ?? []
        // 入力中の文字列を先頭に確保(そのまま確定しやすいように)
        results.removeAll { $0.caseInsensitiveCompare(text) == .orderedSame }
        results.insert(text, at: 0)
        return Array(results.prefix(8))
    }

    /// 候補を選ばずに確定: 無変換のひらがなのまま文書に入れる
    private func commitComposingRaw() {
        guard !composingText.isEmpty else { return }
        let s = composingText
        textDocumentProxy.insertText(s)   // marked text を置き換えて確定
        undoStack.append(.inserted(s)); trimUndo()
        composingText = ""
        candidates = []
        reloadCandidateBar()
        updateReturnKeyTitle()
    }

    /// かな入力として composing に追加できる文字か
    private func isComposable(_ s: String) -> Bool {
        if ["ー", "〜", "、", "。", "？", "！", "…"].contains(s) { return true }
        guard let scalar = s.unicodeScalars.first, s.unicodeScalars.count == 1 else { return false }
        return scalar.value >= 0x3041 && scalar.value <= 0x3096   // ひらがな(ゔ含む)
    }

    private func updateReturnKeyTitle() {
        guard let key = keys.first(where: { if case .newline = $0.action { return true }; return false }) else { return }
        if mode == .abc || isQwertyFamily || !isJapaneseLayout {
            key.titleLabel.text = "return"
        } else {
            key.titleLabel.text = composingText.isEmpty ? "改行" : "確定"
        }
    }

    // MARK: タッチ処理

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let pt = t.location(in: view)
        guard let key = keys.first(where: { $0.frame.contains(pt) }) else { return }
        activeKey = key
        touchStart = pt
        currentDirection = .center
        key.setPressed(true)

        switch key.action {
        case .input(let map):
            if !isQwertyFamily { showGuide(for: key, map: map) }
        case .backspace:
            startBackspaceHold()
        case .space:
            spaceCursorMode = false
            spaceAccumulatedDX = 0
            spaceMoved = false
        default:
            break
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first, let key = activeKey else { return }
        let pt = t.location(in: view)
        let dx = pt.x - touchStart.x
        let dy = pt.y - touchStart.y

        switch key.action {
        case .input:
            let dir = direction(dx: dx, dy: dy)
            if dir != currentDirection {
                currentDirection = dir
                guideView?.highlight(dir, palette: palette)
            }
        case .backspace:
            handleBackspaceSlide(dx: dx)
        case .space:
            handleSpaceSlide(dx: dx)
        default:
            break
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishTouch(cancelled: false)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishTouch(cancelled: true)
    }

    private func finishTouch(cancelled: Bool) {
        defer {
            activeKey?.setPressed(false)
            activeKey = nil
            hideGuide()
            stopBackspace()
        }
        guard let key = activeKey, !cancelled else { return }

        switch key.action {
        case .input(let map):
            let dir = isQwertyFamily ? FlickDirection.center : currentDirection
            if let s = map.value(dir) {
                handleInput(s)
            }
        case .smallDakuten:
            applySmallDakuten()
        case .backspace:
            commitBackspace()
        case .space:
            if !spaceMoved {
                if mode == .kana, !composingText.isEmpty {
                    // 変換中の空白 = 無変換のまま確定(誤変換を防ぐ)
                    commitComposingRaw()
                } else if mode == .qwerty, !composingText.isEmpty {
                    // QWERTY composing 中はスペースで単語確定 + スペース挿入
                    commitComposingRaw()
                    insert(" ")
                } else {
                    insert((mode == .abc || isQwertyFamily || !isJapaneseLayout) ? " " : "　")
                }
            }
        case .newline:
            if !composingText.isEmpty {
                commitComposingRaw()   // 「確定」として動作
            } else {
                insert("\n")
            }
        case .shift:
            break   // shiftKeyTapped が処理
        case .modeKana:
            commitComposingRaw()
            mode = .kana; buildKeyboard()
        case .modeABC:
            commitComposingRaw()
            mode = .abc; buildKeyboard()
        case .modeQWERTY:
            commitComposingRaw()
            mode = .qwerty; buildKeyboard()
        case .mode123:
            commitComposingRaw()
            mode = .number; buildKeyboard()
        case .undo:
            if !composingText.isEmpty {
                setComposing("")   // 変換中: 未確定文字のクリア
            } else {
                performUndo()
            }
        case .globe:
            break   // handleInputModeList が処理
        }
    }

    // MARK: モードキー (UIControl として直接登録)

    @objc private func modeKeyDown(_ sender: KeyView) { sender.alpha = 0.6 }
    @objc private func modeKeyUp(_ sender: KeyView)   { sender.alpha = 1.0 }

    @objc private func modeKeyTapped(_ sender: KeyView) {
        sender.alpha = 1.0
        commitComposingRaw()
        switch sender.action {
        case .modeABC:       mode = .abc
        case .modeKana:      mode = .kana
        case .modeQWERTY:    mode = .qwerty
        case .mode123:       mode = .number
        case .modeQwertyNum: mode = .qwertyNumber
        case .modeQwertySym: mode = .qwertySymbol
        default: return
        }
        UIDevice.current.playInputClick()
        buildKeyboard()
    }

    @objc private func shiftKeyTapped(_ sender: KeyView) {
        sender.alpha = 1.0
        isShifted.toggle()
        updateQwertyCase()
        UIDevice.current.playInputClick()
    }

    private func direction(dx: CGFloat, dy: CGFloat) -> FlickDirection {
        guard hypot(dx, dy) > flickThreshold else { return .center }
        if abs(dx) > abs(dy) {
            return dx < 0 ? .left : .right
        } else {
            return dy < 0 ? .up : .down
        }
    }

    // MARK: フリックガイド

    private func showGuide(for key: KeyView, map: FlickMap) {
        hideGuide()
        let g = FlickGuideView(map: map, palette: palette)
        // キーボード拡張はビュー領域の外に描画できない(描画してもシステムに切られる)ので
        // ガイド全体が必ず領域内に収まるよう上下左右ともクランプする
        let pad: CGFloat = 2
        var c = CGPoint(x: key.center.x, y: key.center.y)
        c.x = min(max(g.bounds.width / 2 + pad, c.x), view.bounds.width - g.bounds.width / 2 - pad)
        c.y = min(max(g.bounds.height / 2 + pad, c.y), view.bounds.height - g.bounds.height / 2 - pad)
        g.center = c
        view.addSubview(g)
        g.highlight(.center, palette: palette)
        guideView = g
    }

    private func hideGuide() {
        guideView?.removeFromSuperview()
        guideView = nil
    }

    // MARK: 入力・取り消し

    private func handleInput(_ s: String) {
        if mode == .kana, isComposable(s) {
            setComposing(composingText + s)
            UIDevice.current.playInputClick()
        } else if mode == .qwerty, s.count == 1, s.first?.isLetter == true {
            // QWERTY 英字 → composing バッファに積んで予測候補を表示
            let c = isShifted ? s.uppercased() : s
            if isShifted { isShifted = false; updateQwertyCase() }
            setComposing(composingText + c)
            UIDevice.current.playInputClick()
        } else {
            commitComposingRaw()
            let output: String
            if mode == .qwerty && isShifted {
                output = s.uppercased()
                isShifted = false
                updateQwertyCase()
            } else {
                output = s
            }
            insert(output)
        }
    }

    private func insert(_ s: String) {
        textDocumentProxy.insertText(s)
        undoStack.append(.inserted(s))
        trimUndo()
        UIDevice.current.playInputClick()
    }

    private func performUndo() {
        guard let op = undoStack.popLast() else { return }
        switch op {
        case .inserted(let s):
            for _ in 0..<s.count { textDocumentProxy.deleteBackward() }
        case .deleted(let s):
            textDocumentProxy.insertText(s)
        }
    }

    private func trimUndo() {
        if undoStack.count > 30 { undoStack.removeFirst(undoStack.count - 30) }
    }

    // MARK: 小゛゜ / a/A

    private func applySmallDakuten() {
        if mode == .kana, !composingText.isEmpty {
            // 変換中: composing の末尾文字を循環
            guard let last = composingText.last, let next = dakutenNext(for: String(last)) else { return }
            setComposing(String(composingText.dropLast()) + next)
            UIDevice.current.playInputClick()
            return
        }
        guard let before = textDocumentProxy.documentContextBeforeInput,
              let last = before.last else { return }
        let ch = String(last)
        if mode == .abc {
            // a/A: 直前の英字の大文字小文字をトグル(純正準拠)
            let toggled = ch == ch.lowercased() ? ch.uppercased() : ch.lowercased()
            guard toggled != ch else { return }
            textDocumentProxy.deleteBackward()
            textDocumentProxy.insertText(toggled)
        } else {
            guard let next = dakutenNext(for: ch) else { return }
            textDocumentProxy.deleteBackward()
            textDocumentProxy.insertText(next)
        }
        UIDevice.current.playInputClick()
    }

    // MARK: バックスペース (長押し連続削除 + 左スライド範囲削除)

    private func startBackspaceHold() {
        bsRangeMode = false
        bsRangeCount = 0
        bsDeletedDuringHold = false
        // 0.4秒後から連続削除(純正準拠)、徐々に加速
        var interval = 0.12
        bsRepeatTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.deleteOnce()
            self.bsRepeatTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                self?.deleteOnce()
                interval = max(0.05, interval * 0.93)
            }
        }
    }

    private func deleteOnce() {
        guard !bsRangeMode else { return }
        // 変換中は composing の末尾から消す
        if !composingText.isEmpty {
            setComposing(String(composingText.dropLast()))
            bsDeletedDuringHold = true
            return
        }
        guard let before = textDocumentProxy.documentContextBeforeInput, !before.isEmpty else { return }
        let last = String(before.last!)
        textDocumentProxy.deleteBackward()
        undoStack.append(.deleted(last))
        trimUndo()
        bsDeletedDuringHold = true
    }

    private func handleBackspaceSlide(dx: CGFloat) {
        guard dx < -12 || bsRangeMode else { return }
        if !bsRangeMode {
            bsRangeMode = true
            bsRepeatTimer?.invalidate()
            bsRepeatTimer = nil
            // 範囲削除は文書に対して行う: 変換中の文字は先に無変換確定してから対象にする
            commitComposingRaw()
            showDeletePreview()
        }
        let available = textDocumentProxy.documentContextBeforeInput?.count ?? 0
        bsRangeCount = min(available, max(0, Int(-dx / bsRangeStep)))
        updateDeletePreview()
    }

    private func showDeletePreview() {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.font = palette.keyFont(size: 14, weight: .semibold)
        lb.textColor = .white
        lb.backgroundColor = UIColor.systemRed.withAlphaComponent(0.92)
        lb.layer.cornerRadius = 10
        lb.layer.masksToBounds = true
        view.addSubview(lb)
        bsPreviewLabel = lb
        updateDeletePreview()
    }

    private func updateDeletePreview() {
        guard let lb = bsPreviewLabel else { return }
        if bsRangeCount == 0 {
            lb.text = "◀ スライドで削除"
        } else {
            let before = textDocumentProxy.documentContextBeforeInput ?? ""
            var snippet = String(before.suffix(bsRangeCount))
            if snippet.count > 12 { snippet = "…" + snippet.suffix(11) }
            lb.text = snippet
        }
        lb.sizeToFit()
        let w = lb.bounds.width + 24
        lb.frame = CGRect(x: view.bounds.width - w - 8, y: 6, width: w, height: 30)
    }

    private func commitBackspace() {
        if bsRangeMode {
            if bsRangeCount > 0 {
                let before = textDocumentProxy.documentContextBeforeInput ?? ""
                let removed = String(before.suffix(bsRangeCount))
                for _ in 0..<bsRangeCount { textDocumentProxy.deleteBackward() }
                undoStack.append(.deleted(removed))
                trimUndo()
                UIDevice.current.playInputClick()
            }
        } else if !bsDeletedDuringHold {
            deleteOnce()   // 通常タップ: 1文字削除
        }
    }

    private func stopBackspace() {
        bsRepeatTimer?.invalidate()
        bsRepeatTimer = nil
        bsPreviewLabel?.removeFromSuperview()
        bsPreviewLabel = nil
        bsRangeMode = false
        bsRangeCount = 0
    }

    // MARK: 空白キーのカーソル移動

    private func handleSpaceSlide(dx: CGFloat) {
        if !spaceCursorMode, abs(dx) > 14 {
            spaceCursorMode = true
            spaceAccumulatedDX = dx
            // marked text があるままのカーソル移動は挙動が不定なので先に確定
            commitComposingRaw()
        }
        guard spaceCursorMode else { return }
        let delta = dx - spaceAccumulatedDX
        let steps = Int(delta / bsRangeStep)
        if steps != 0 {
            textDocumentProxy.adjustTextPosition(byCharacterOffset: steps)
            spaceAccumulatedDX += CGFloat(steps) * bsRangeStep
            spaceMoved = true
        }
    }

    // MARK: テーマピッカー

    private var themePickerView: ThemePickerView?

    @objc private func themeButtonTapped(_ sender: KeyView) {
        sender.alpha = 1.0
        if themePickerView != nil {
            hideThemePicker()
        } else {
            showThemePicker()
        }
        UIDevice.current.playInputClick()
    }

    private func showThemePicker() {
        hideThemePicker()
        let picker = ThemePickerView(
            current: theme,
            palette: palette,
            darkMode: traitCollection.userInterfaceStyle == .dark
        )
        picker.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 42)
        picker.onSelect = { [weak self] selected in
            guard let self else { return }
            self.theme = selected
            self.theme.save()
            self.applyTheme()
            self.hideThemePicker()
            self.showThemeToast()
        }
        view.addSubview(picker)
        themePickerView = picker
    }

    private func hideThemePicker() {
        themePickerView?.removeFromSuperview()
        themePickerView = nil
    }

    // MARK: QWERTY レイアウト

    private func buildQwertyKeys() {
        // モードキー生成ヘルパー
        func makeSpecial(_ action: KeyAction, text: String, tag: Int, accent: Bool = false) {
            let key = KeyView(action: action)
            key.titleLabel.text = text
            key.isSpecial = !accent; key.isAccent = accent
            key.tag = tag
            key.isUserInteractionEnabled = true
            key.addTarget(self, action: #selector(modeKeyTapped(_:)), for: .touchUpInside)
            key.addTarget(self, action: #selector(modeKeyDown(_:)), for: .touchDown)
            key.addTarget(self, action: #selector(modeKeyUp(_:)), for: [.touchUpOutside, .touchCancel])
            view.addSubview(key); keys.append(key)
        }
        func makeInput(_ c: String, tag: Int) {
            let key = KeyView(action: .input(FlickMap(center: c, left: nil, up: nil, right: nil, down: nil)))
            key.titleLabel.text = c; key.tag = tag
            view.addSubview(key); keys.append(key)
        }

        switch mode {
        case .qwerty:
            // Row 0: Q-P (tags 1000-1009)
            for (i, ch) in "qwertyuiop".enumerated() { makeInput(String(ch), tag: 1000 + i) }
            // Row 1: A-L (tags 1020-1028, 9キー中央寄せ)
            for (i, ch) in "asdfghjkl".enumerated() { makeInput(String(ch), tag: 1020 + i) }
            // Row 2: ⇧(1040), Z-M(1041-1047), ⌫(1048)
            let shiftKey = KeyView(action: .shift)
            configure(shiftKey, action: .shift); shiftKey.tag = 1040
            view.addSubview(shiftKey); keys.append(shiftKey)
            for (i, ch) in "zxcvbnm".enumerated() { makeInput(String(ch), tag: 1041 + i) }
            let bsKey = KeyView(action: .backspace)
            bsKey.titleLabel.text = "⌫"; bsKey.isSpecial = true; bsKey.tag = 1048
            view.addSubview(bsKey); keys.append(bsKey)
            // Row 3: 123(1060) / あいう or abc(1061) / space(1062) / .(1063) / return(1064)
            makeSpecial(.modeQwertyNum, text: "123", tag: 1060)
            if isJapaneseLayout { makeSpecial(.modeKana, text: "あいう", tag: 1061) }
            else                 { makeSpecial(.modeABC,  text: "abc",   tag: 1061) }
            let spaceKey = KeyView(action: .space)
            spaceKey.titleLabel.text = "space"; spaceKey.isSpecial = true; spaceKey.tag = 1062
            view.addSubview(spaceKey); keys.append(spaceKey)
            makeInput(".", tag: 1063)
            let returnKey = KeyView(action: .newline)
            returnKey.titleLabel.text = "return"; returnKey.isAccent = true; returnKey.tag = 1064
            view.addSubview(returnKey); keys.append(returnKey)

        case .qwertyNumber, .qwertySymbol:
            let isNum = (mode == .qwertyNumber)
            // Row 0: 数字 or 記号 (tags 1000-1009, 10キー)
            let row0 = isNum ? Array("1234567890") : Array("[]{}#%^*+=")
            for (i, ch) in row0.enumerated() { makeInput(String(ch), tag: 1000 + i) }
            // Row 1: 記号 (tags 1020-1029, 10キー)
            let row1: [String] = isNum
                ? ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""]
                : ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"]
            for (i, c) in row1.enumerated() { makeInput(c, tag: 1020 + i) }
            // Row 2: #+=or123(1040), . , ? ! '(1041-1045), ⌫(1048)
            makeSpecial(isNum ? .modeQwertySym : .modeQwertyNum,
                        text: isNum ? "#+=" : "123", tag: 1040)
            for (i, c) in [".", ",", "?", "!", "'"].enumerated() { makeInput(c, tag: 1041 + i) }
            let bsKey2 = KeyView(action: .backspace)
            bsKey2.titleLabel.text = "⌫"; bsKey2.isSpecial = true; bsKey2.tag = 1048
            view.addSubview(bsKey2); keys.append(bsKey2)
            // Row 3: ABC(1060) / space(1062) / return(1064)
            makeSpecial(.modeQWERTY, text: "ABC", tag: 1060)
            let spaceKey2 = KeyView(action: .space)
            spaceKey2.titleLabel.text = "space"; spaceKey2.isSpecial = true; spaceKey2.tag = 1062
            view.addSubview(spaceKey2); keys.append(spaceKey2)
            let returnKey2 = KeyView(action: .newline)
            returnKey2.titleLabel.text = "return"; returnKey2.isAccent = true; returnKey2.tag = 1064
            view.addSubview(returnKey2); keys.append(returnKey2)

        default:
            break
        }

        applyTheme()
        view.setNeedsLayout()
    }

    private func layoutQwertyKeys() {
        let m: CGFloat = 5
        let outerH: CGFloat = 4, outerV: CGFloat = 3
        let top = topBarHeight + outerV
        let totalW = view.bounds.width - outerH * 2
        let totalH = view.bounds.height - top - outerV
        guard totalW > 0, totalH > 0 else { return }
        let rowH = (totalH - m * 3) / 4
        let keyW = (totalW - m * 9) / 10   // 10キー基準幅
        let wideW = keyW * 1.5              // ⇧/⌫ / #+=/ ABC の幅
        let isNumSym = mode == .qwertyNumber || mode == .qwertySymbol

        for key in keys {
            let t = key.tag
            guard t >= 1000 else { continue }
            let row = (t - 1000) / 20
            let col = (t - 1000) % 20
            let y = top + CGFloat(row) * (rowH + m)
            var x: CGFloat
            var w: CGFloat = keyW

            switch row {
            case 0: // 10キー全幅 (QWERTY: Q-P / numSym: 数字/記号)
                x = outerH + CGFloat(col) * (keyW + m)

            case 1:
                if isNumSym {
                    // 10キー全幅
                    x = outerH + CGFloat(col) * (keyW + m)
                } else {
                    // 9キー中央寄せ (A-L)
                    let row1W = keyW * 9 + m * 8
                    let indent = (totalW - row1W) / 2
                    x = outerH + indent + CGFloat(col) * (keyW + m)
                }

            case 2:
                if col == 0 {       // 左ワイドキー: ⇧ / #+= / 123
                    x = outerH; w = wideW
                } else if col == 8 { // ⌫ (常に右端 col=8)
                    x = outerH + totalW - wideW; w = wideW
                } else {
                    // 中間キー: QWERTY=7個(z-m), numSym=5個(. , ? ! ')
                    let numMid: Int = isNumSym ? 5 : 7
                    let midW = totalW - wideW * 2 - m * 2
                    let midKeyW = (midW - m * CGFloat(numMid - 1)) / CGFloat(numMid)
                    x = outerH + wideW + m + CGFloat(col - 1) * (midKeyW + m)
                    w = midKeyW
                }

            case 3:
                if isNumSym {
                    // ABC(wideW) + space(残り) + return(wideW), 2ギャップ
                    switch col {
                    case 0: x = outerH;                           w = wideW
                    case 2: x = outerH + wideW + m;              w = totalW - wideW * 2 - m * 2
                    case 4: x = outerH + totalW - wideW;         w = wideW
                    default: x = 0
                    }
                } else {
                    // 123(1.5u) + あいう/abc(1.5u) + space(3u) + .(1u) + return(1u) = 8u, 4ギャップ
                    let unit = (totalW - m * 4) / 8
                    switch col {
                    case 0: x = outerH;                           w = unit * 1.5
                    case 1: x = outerH + unit * 1.5 + m;          w = unit * 1.5
                    case 2: x = outerH + unit * 3 + m * 2;        w = unit * 3
                    case 3: x = outerH + unit * 6 + m * 3;        w = unit * 1.0
                    case 4: x = outerH + unit * 7 + m * 4;        w = unit * 1.0
                    default: x = 0
                    }
                }

            default: x = 0
            }

            key.frame = CGRect(x: x, y: y, width: w, height: rowH)
            let base = min(w, rowH)
            switch key.action {
            case .input:
                key.titleLabel.font = palette.keyFont(size: base * 0.48, weight: .regular)
            default:
                key.titleLabel.font = palette.keyFont(size: base * 0.28, weight: .medium)
            }
        }
    }

    private func updateQwertyCase() {
        for key in keys {
            guard key.tag >= 1000, key.tag < 1040 else { continue }
            if case .input(let map) = key.action {
                key.titleLabel.text = isShifted ? map.center.uppercased() : map.center
            }
        }
        if let shiftKey = keys.first(where: { if case .shift = $0.action { return true }; return false }) {
            shiftKey.titleLabel.text = isShifted ? "⇪" : "⇧"
        }
    }

    private func showThemeToast() {
        let lb = UILabel()
        lb.text = "テーマ: \(theme.displayName)"
        lb.font = palette.keyFont(size: 14, weight: .semibold)
        lb.textColor = palette.popupText
        lb.backgroundColor = palette.popupBg
        lb.textAlignment = .center
        lb.layer.cornerRadius = 10
        lb.layer.masksToBounds = true
        lb.sizeToFit()
        lb.frame = CGRect(x: (view.bounds.width - lb.bounds.width - 28) / 2, y: 6,
                          width: lb.bounds.width + 28, height: 30)
        view.addSubview(lb)
        UIView.animate(withDuration: 0.3, delay: 1.0, options: []) {
            lb.alpha = 0
        } completion: { _ in lb.removeFromSuperview() }
    }
}

// MARK: - クリック音

extension KeyboardViewController: UIInputViewAudioFeedback {
    var enableInputClicksWhenVisible: Bool { true }
}
