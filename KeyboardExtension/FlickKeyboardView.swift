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

// MARK: - Callout shape (rounded rect + downward triangle)

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

// MARK: - Callout preference (lifts callout to top of keyboard view)

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

// Renders the callout at keyboard-level coordinate space (on top of everything)
private struct FlickCalloutView: View {
    let data: FlickCalloutData
    let keyRect: CGRect

    // If callout would overflow keyboard top, flip it downward automatically
    private var effectiveDir: FlickDirection {
        if (data.dir == .center || data.dir == .up) && keyRect.minY < 62 { return .down }
        return data.dir
    }

    private var size: CGSize {
        switch effectiveDir {
        case .center, .up, .down: return CGSize(width: 52, height: 61)
        case .left, .right:       return CGSize(width: 61, height: 50)
        }
    }

    private var side: CalloutShape.Side {
        switch effectiveDir {
        case .center, .up: return .bottom
        case .down:        return .top
        case .left:        return .right
        case .right:       return .left
        }
    }

    private var textOffset: CGSize {
        let t: CGFloat = 3.5
        switch effectiveDir {
        case .center, .up: return CGSize(width: 0, height: -t)
        case .down:        return CGSize(width: 0, height:  t)
        case .left:        return CGSize(width: -t, height: 0)
        case .right:       return CGSize(width:  t, height: 0)
        }
    }

    private var center: CGPoint {
        let s = size
        switch effectiveDir {
        case .center, .up:
            return CGPoint(x: keyRect.midX, y: keyRect.minY - s.height / 2)
        case .down:
            return CGPoint(x: keyRect.midX, y: keyRect.maxY + s.height / 2)
        case .left:
            return CGPoint(x: keyRect.minX - s.width / 2, y: keyRect.midY)
        case .right:
            return CGPoint(x: keyRect.maxX + s.width / 2, y: keyRect.midY)
        }
    }

    var body: some View {
        let s = size
        ZStack {
            CalloutShape(side: side)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.35), radius: 4, x: 0, y: 2)
            Text(data.chars.char(for: data.dir) ?? data.chars.center)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(data.isFlicking ? .accentColor : Color(UIColor.label))
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

    @State private var dir: FlickDirection = .center
    @State private var isActive = false
    @State private var isFlicking = false
    private let threshold: CGFloat = 22

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(isActive ? Color(UIColor.systemGray4) : Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.3), radius: 0, x: 0, y: 1)

            if isFlicking {
                Text(chars.char(for: dir) ?? chars.center)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.accentColor)
            } else {
                Text(chars.center)
                    .font(.system(size: 18))
                    .foregroundColor(Color(UIColor.label))
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

    // 標準フリック配列: 左=い, 上=う, 右=え, 下=お
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

    // 数字・記号グリッド
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

    // 上フリック専用: 小文字変換のみ
    private let smallOnlyCycle: [Character: Character] = [
        "あ":"ぁ","ぁ":"あ","い":"ぃ","ぃ":"い","う":"ぅ","ぅ":"う",
        "え":"ぇ","ぇ":"え","お":"ぉ","ぉ":"お",
        "つ":"っ","っ":"つ","づ":"っ",
        "や":"ゃ","ゃ":"や","ゆ":"ゅ","ゅ":"ゆ","よ":"ょ","ょ":"よ","わ":"ゎ","ゎ":"わ",
    ]

    // 濁点→半濁点→小文字→元 の順でサイクル（標準iOSキーボード準拠）
    private let modifierCycle: [Character: Character] = {
        var m: [Character: Character] = [:]
        let cycles: [[Character]] = [
            ["か","が"],["き","ぎ"],["く","ぐ"],["け","げ"],["こ","ご"],
            ["さ","ざ"],["し","じ"],["す","ず"],["せ","ぜ"],["そ","ぞ"],
            ["た","だ"],["ち","ぢ"],["て","で"],["と","ど"],
            ["つ","っ","づ"],           // 小文字→濁点→元
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

    // 高さ計算: topBar(36) + padTop(3) + grid(4*44+3*3=185) + padBot(3) = 227px
    // 右列: ⌫(44) + sp(3) + 空白(44) + sp(3) + 改行(44*2+3=91) = 185 ✓
    // 全カラム maxWidth:.infinity で5等分 (左機能+かな3+右機能)
    private let keySize: CGFloat = 44
    private let sp: CGFloat = 3

    var body: some View {
        VStack(spacing: 0) {
            topBar

            // 5列を maxWidth:.infinity で均等幅に
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
        .onChange(of: composingText) { newText in
            if newText.isEmpty {
                candidates = []
                onUnmarkText()
            } else {
                candidates = KanjiConverter.shared.candidates(for: newText)
                // 入力欄にひらがなを下線付きで表示（標準IME動作）
                onSetMarkedText(newText)
            }
        }
        .onChange(of: slideCount) { newCount in
            if newCount > 0 {
                let before = getContextBefore()
                // marked textがdocumentContextBeforeInputに含まれない場合があるため補完
                contextBefore = (!composingText.isEmpty && !before.hasSuffix(composingText))
                    ? before + composingText
                    : before
            }
        }
        .overlayPreferenceValue(FlickCalloutKey.self) { data in
            if let data = data {
                GeometryReader { proxy in
                    FlickCalloutView(data: data, keyRect: proxy[data.anchor])
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
            Color.clear.frame(maxWidth: .infinity, minHeight: keySize, maxHeight: keySize)
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
    // topBar高さを36pxに抑えることで総高さ227px → 候補欄が上で切れない
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
        // カーソルから遡る28文字ウィンドウで左端を省略し、境界を常に表示
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
            cornerRadius: 6,
            iconSize: 17,
            onTap: {
                if !composingText.isEmpty {
                    composingText = String(composingText.dropLast())
                } else { onBackspace() }
            },
            onSlideDelete: { count in
                if !composingText.isEmpty {
                    if count <= composingText.count {
                        // 入力中の文字列内で収まる → 確定せず composingText から削る
                        composingText = String(composingText.dropLast(count))
                    } else {
                        // 入力中を超える → unmark してドキュメントから count 文字削除
                        // (unmark 後の deleteBackward が composing 分も含めて count 文字削る)
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
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
                .overlay(
                    Text("空白")
                        .font(.system(size: 13))
                        .foregroundColor(Color(UIColor.label))
                )
        }
        .buttonStyle(.plain)
    }

    private var returnKey: some View {
        Button(action: {
            if !composingText.isEmpty {
                onInsert(composingText)
                composingText = ""; candidates = []
            } else {
                onReturn()
            }
        }) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(UIColor.systemGray3))
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
                .overlay(
                    Text(composingText.isEmpty ? "改行" : "確定")
                        .font(.system(size: 15))
                        .foregroundColor(Color(UIColor.label))
                )
        }
        .buttonStyle(.plain)
    }

    private var switchKey: some View {
        Button(action: {
            commitComposing()
            onSwitchToEnglish()
        }) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(UIColor.systemGray3))
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
                .overlay(
                    Text("ABC")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(UIColor.label))
                )
        }
        .buttonStyle(.plain)
    }

    private var globeKey: some View {
        Button(action: {
            commitComposing()
            onNextKeyboard()
        }) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(UIColor.systemGray3))
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
                .overlay(
                    Image(systemName: "globe")
                        .font(.system(size: 16))
                        .foregroundColor(Color(UIColor.label))
                )
        }
        .buttonStyle(.plain)
    }

    private var numberToggleKey: some View {
        Button(action: {
            commitComposing()
            isNumberMode.toggle()
        }) {
            RoundedRectangle(cornerRadius: 6)
                .fill(isNumberMode ? Color.accentColor.opacity(0.2) : Color(UIColor.systemGray3))
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
                .overlay(
                    Text(isNumberMode ? "かな" : "☆123")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(UIColor.label))
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Input handling

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
            if char == "小" {
                applyModifier(smallOnlyCycle)
            } else {
                applyModifier(modifierCycle)
            }
        } else if isHiragana(char) || char == "ー" {
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
