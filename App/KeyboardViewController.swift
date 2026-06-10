import UIKit

// =====================================================================
// SwipeDelete Keyboard — キーボード拡張本体
//
// ・配置/挙動は iOS 純正12キー(フリック)に準拠
//     左列:  ⤺ / ☆123 / ABC / 🌐   右列: ⌫ / 空白 / 改行(2行分)
//     かな:  あかさ / たなは / まやら / 小゛゜ わ 、。?!
// ・独自機能は「⌫ を押したまま左へスライド → 削除範囲を選んで一括削除」のみ
// ・追加の便利機能(純正準拠):
//     - 空白キーを左右にスライドでカーソル移動
//     - ⌫ 長押しで連続削除(加速つき)
//     - 小゛゜キーで 小文字/濁点/半濁点 をタップ循環
//     - ⤺ で直前の入力/削除を取り消し
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
    let popupBg: UIColor          // フリックガイド/削除プレビュー
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

    static func load() -> KeyboardTheme {
        let ud = UserDefaults(suiteName: suiteName) ?? .standard
        return KeyboardTheme(rawValue: ud.string(forKey: storageKey) ?? "") ?? .system
    }

    func save() {
        let ud = UserDefaults(suiteName: KeyboardTheme.suiteName) ?? .standard
        ud.set(rawValue, forKey: KeyboardTheme.storageKey)
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
    case mode123
    case globe
    case undo
}

enum KeyboardMode { case kana, abc, number }

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

// 小゛゜のタップ循環テーブル
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
        isExclusiveTouch = true
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
            bubble.backgroundColor = on ? palette.popupHighlight : palette.popupBg
            labels[dir]?.textColor = on ? .white : palette.popupText
            bubble.transform = on ? CGAffineTransform(scaleX: 1.15, y: 1.15) : .identity
        }
    }
}

// MARK: - メイン ViewController

final class KeyboardViewController: UIInputViewController {

    private var mode: KeyboardMode = .kana
    private var theme = KeyboardTheme.load()
    private var palette: ThemePalette {
        theme.palette(darkMode: traitCollection.userInterfaceStyle == .dark)
    }

    private var keys: [KeyView] = []
    private var heightConstraint: NSLayoutConstraint?

    // フリック状態
    private var activeKey: KeyView?
    private var touchStart: CGPoint = .zero
    private var currentDirection: FlickDirection = .center
    private var guideView: FlickGuideView?
    private let flickThreshold: CGFloat = 16

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
        buildKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if heightConstraint == nil {
            let h = NSLayoutConstraint(item: view!, attribute: .height, relatedBy: .equal,
                                       toItem: nil, attribute: .notAnAttribute,
                                       multiplier: 1, constant: 236)
            h.priority = .init(999)
            view.addConstraint(h)
            heightConstraint = h
        }
        theme = KeyboardTheme.load()   // 本体アプリでの変更を反映
        applyTheme()
    }

    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        applyTheme()
    }

    // MARK: 構築

    private func buildKeyboard() {
        keys.forEach { $0.removeFromSuperview() }
        keys.removeAll()

        // 5列 × 4行 (改行は右列の3-4行を結合)
        var grid: [[KeyAction?]] = Array(repeating: Array(repeating: nil, count: 5), count: 4)

        // 左列(純正準拠): ⤺ / ☆123 / ABC / 🌐 — モードにより表示が入れ替わる
        grid[0][0] = .undo
        switch mode {
        case .kana:
            grid[1][0] = .mode123
            grid[2][0] = .modeABC
        case .abc:
            grid[1][0] = .mode123
            grid[2][0] = .modeKana
        case .number:
            grid[1][0] = .modeKana
            grid[2][0] = .modeABC
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
            key.titleLabel.text = (mode == .abc) ? "space" : "空白"; key.isSpecial = true
        case .newline:
            key.titleLabel.text = (mode == .abc) ? "return" : "改行"; key.isAccent = true
        case .modeKana:
            key.titleLabel.text = "あいう"; key.isSpecial = true
        case .modeABC:
            key.titleLabel.text = "ABC"; key.isSpecial = true
        case .mode123:
            key.titleLabel.text = "☆123"; key.isSpecial = true
        case .globe:
            key.titleLabel.text = "🌐"; key.isSpecial = true
            // 純正同様、地球儀はシステムの入力切替を呼ぶ
            key.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        case .undo:
            key.titleLabel.text = "⤺"; key.isSpecial = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutKeys()
    }

    private func layoutKeys() {
        let m: CGFloat = 3                                  // キー間マージン
        let outerH: CGFloat = 3, outerV: CGFloat = 5
        let w = view.bounds.width - outerH * 2
        let h = view.bounds.height - outerV * 2
        guard w > 0, h > 0 else { return }
        let colW = (w - m * 4) / 5
        let rowH = (h - m * 3) / 4

        for key in keys {
            let r = key.tag / 10, c = key.tag % 10
            var f = CGRect(x: outerH + CGFloat(c) * (colW + m),
                           y: outerV + CGFloat(r) * (rowH + m),
                           width: colW, height: rowH)
            if case .newline = key.action {
                f.size.height = rowH * 2 + m               // 改行は2行分
            }
            key.frame = f
            let base = min(colW, rowH)
            switch key.action {
            case .input:
                key.titleLabel.font = palette.keyFont(size: base * 0.42, weight: .regular)
            case .space, .newline, .modeKana, .modeABC, .mode123, .smallDakuten:
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
            showGuide(for: key, map: map)
        case .backspace:
            startBackspaceHold()
        case .space:
            spaceCursorMode = false
            spaceAccumulatedDX = 0
            spaceMoved = false
        case .undo:
            scheduleThemeCyclePress()
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
            if hypot(dx, dy) > 30 { cancelThemeCyclePress() }
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
            cancelThemeCyclePress()
        }
        guard let key = activeKey, !cancelled else { return }

        switch key.action {
        case .input(let map):
            if let s = map.value(currentDirection) {
                insert(s)
            }
        case .smallDakuten:
            applySmallDakuten()
        case .backspace:
            commitBackspace()
        case .space:
            if !spaceMoved {
                insert(mode == .abc ? " " : "　")
            }
        case .newline:
            insert("\n")
        case .modeKana:
            mode = .kana; buildKeyboard()
        case .modeABC:
            mode = .abc; buildKeyboard()
        case .mode123:
            mode = .number; buildKeyboard()
        case .undo:
            if !themeCycled { performUndo() }
        case .globe:
            break   // handleInputModeList が処理
        }
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
        g.center = CGPoint(x: key.center.x,
                           y: max(g.bounds.height / 2 - 8, key.center.y - 10))
        // 画面端でのはみ出しを補正
        let pad: CGFloat = 4
        if g.frame.minX < pad { g.frame.origin.x = pad }
        if g.frame.maxX > view.bounds.width - pad { g.frame.origin.x = view.bounds.width - pad - g.bounds.width }
        view.addSubview(g)
        g.highlight(.center, palette: palette)
        guideView = g
    }

    private func hideGuide() {
        guideView?.removeFromSuperview()
        guideView = nil
    }

    // MARK: 入力・取り消し

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
            lb.text = "◀ スライドで削除範囲を選択"
        } else {
            let before = textDocumentProxy.documentContextBeforeInput ?? ""
            var snippet = String(before.suffix(bsRangeCount))
            if snippet.count > 12 { snippet = "…" + snippet.suffix(11) }
            lb.text = "「\(snippet)」を削除 (\(bsRangeCount)文字)"
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

    // MARK: ⤺ 長押しでテーマ切替

    private var themeCycleTimer: Timer?
    private var themeCycled = false

    private func scheduleThemeCyclePress() {
        themeCycled = false
        themeCycleTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.theme = self.theme.next
            self.theme.save()
            self.applyTheme()
            self.themeCycled = true
            self.showThemeToast()
        }
    }

    private func cancelThemeCyclePress() {
        themeCycleTimer?.invalidate()
        themeCycleTimer = nil
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
