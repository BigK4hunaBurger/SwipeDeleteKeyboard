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
                .fill(isActive ? Color(UIColor.systemGray2) : Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.3), radius: 0, x: 0, y: 1)

            if isFlicking {
                Text(chars.char(for: dir) ?? chars.center)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.accentColor)
            } else {
                VStack(spacing: 0) {
                    Text(chars.up ?? " ")
                        .font(.system(size: 8))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                    HStack(spacing: 0) {
                        Text(chars.left ?? " ")
                            .font(.system(size: 8))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                            .frame(width: 10)
                        Text(chars.center)
                            .font(.system(size: 16))
                            .foregroundColor(Color(UIColor.label))
                            .frame(minWidth: 14)
                        Text(chars.right ?? " ")
                            .font(.system(size: 8))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                            .frame(width: 10)
                    }
                    Text(chars.down ?? " ")
                        .font(.system(size: 8))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
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
        [FlickChars("、", left:"。", up:"？", right:"！", down:"…"),
         FlickChars("わ", left:"を", up:"ん", right:"ー", down:"〜"),
         FlickChars("゛", left:"ゅ", up:"ゃ", right:"ょ", down:"っ")],
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

    private let dakutenCycle: [Character: Character] = {
        var m: [Character: Character] = [:]
        let pairs: [[Character]] = [
            ["か","が"],["き","ぎ"],["く","ぐ"],["け","げ"],["こ","ご"],
            ["さ","ざ"],["し","じ"],["す","ず"],["せ","ぜ"],["そ","ぞ"],
            ["た","だ"],["ち","ぢ"],["つ","づ"],["て","で"],["と","ど"],
            ["は","ば","ぱ"],["ひ","び","ぴ"],["ふ","ぶ","ぷ"],
            ["へ","べ","ぺ"],["ほ","ぼ","ぽ"],
        ]
        for cycle in pairs {
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
        .background(Color(UIColor.systemGray5))
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
            if newCount > 0 { contextBefore = getContextBefore() }
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
        if !candidates.isEmpty {
            candidateBar
        } else if slideCount > 0 {
            deletionPreview
        } else {
            Color.clear.frame(height: 36)
        }
    }

    private var candidateBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                if !composingText.isEmpty {
                    Text(composingText)
                        .font(.system(size: 13))
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
                            .font(.system(size: 15))
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
        .background(Color(UIColor.systemGray6))
    }

    private var deletionPreview: some View {
        let all = Array(contextBefore)
        let del = min(slideCount, all.count)
        let keep = String(String(all.prefix(all.count - del)).suffix(20))
        let deleted = String(String(all.suffix(del)).suffix(20))

        return HStack(spacing: 0) {
            Spacer(minLength: 8)
            HStack(spacing: 0) {
                Text(keep).foregroundColor(Color(UIColor.label))
                Text(deleted).foregroundColor(.white).background(Color.red)
                Text("｜").foregroundColor(Color(UIColor.label))
            }
            .font(.system(size: 13)).lineLimit(1)
            .padding(.horizontal, 10).padding(.vertical, 3)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(6)
            Spacer(minLength: 8)
        }
        .frame(height: 36)
        .background(Color(UIColor.systemGray6))
    }

    // MARK: - Function keys

    private var backspaceKey: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(slideCount > 0 ? Color.red.opacity(0.15) : Color(UIColor.systemGray3))
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
            Image(systemName: "delete.left")
                .font(.system(size: 15))
                .foregroundColor(slideCount > 0 ? .red : Color(UIColor.label))
                .allowsHitTesting(false)
            BackspaceButton(
                onTap: {
                    if !composingText.isEmpty {
                        composingText = String(composingText.dropLast())
                    } else { onBackspace() }
                },
                onSlideDelete: { count in
                    if !composingText.isEmpty {
                        composingText = ""; candidates = []
                    } else {
                        withAnimation(.easeOut(duration: 0.1)) { slideCount = 0 }
                        onBackspaceSlide(count)
                    }
                },
                onCountChange: { count in
                    if composingText.isEmpty {
                        withAnimation(.easeInOut(duration: 0.1)) { slideCount = count }
                    }
                }
            )
        }
    }

    private var spaceKey: some View {
        Button(action: {
            if !composingText.isEmpty {
                let first = candidates.first ?? composingText
                onInsert(first)
                composingText = ""; candidates = []
            } else {
                onInsert("　")
            }
        }) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
                .overlay(
                    Text(composingText.isEmpty ? "空白" : "確定")
                        .font(.system(size: 11))
                        .foregroundColor(Color(UIColor.label))
                )
        }
        .buttonStyle(.plain)
    }

    private var returnKey: some View {
        Button(action: {
            if !composingText.isEmpty {
                onInsert(composingText); composingText = ""; candidates = []
            }
            onReturn()
        }) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(UIColor.systemGray3))
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
                .overlay(
                    Text("改行")
                        .font(.system(size: 13))
                        .foregroundColor(Color(UIColor.label))
                )
        }
        .buttonStyle(.plain)
    }

    private var switchKey: some View {
        Button(action: {
            if !composingText.isEmpty { onInsert(composingText); composingText = ""; candidates = [] }
            onSwitchToEnglish()
        }) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(UIColor.systemGray3))
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
                .overlay(
                    Text("ABC")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(UIColor.label))
                )
        }
        .buttonStyle(.plain)
    }

    private var globeKey: some View {
        Button(action: {
            if !composingText.isEmpty { onInsert(composingText); composingText = ""; candidates = [] }
            onNextKeyboard()
        }) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(UIColor.systemGray3))
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
                .overlay(
                    Image(systemName: "globe")
                        .font(.system(size: 14))
                        .foregroundColor(Color(UIColor.label))
                )
        }
        .buttonStyle(.plain)
    }

    private var numberToggleKey: some View {
        Button(action: {
            if !composingText.isEmpty { onInsert(composingText); composingText = ""; candidates = [] }
            isNumberMode.toggle()
        }) {
            RoundedRectangle(cornerRadius: 6)
                .fill(isNumberMode ? Color.accentColor.opacity(0.2) : Color(UIColor.systemGray3))
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
                .overlay(
                    Text(isNumberMode ? "かな" : "☆123")
                        .font(.system(size: 10, weight: .semibold))
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

    private func handleSelect(_ char: String, fromKey chars: FlickChars) {
        if isNumberMode {
            if !composingText.isEmpty { onInsert(composingText); composingText = "" }
            onInsert(char)
            return
        }

        if chars.center == "゛" {
            if !composingText.isEmpty {
                if let last = composingText.last, let next = dakutenCycle[last] {
                    composingText = String(composingText.dropLast()) + String(next)
                } else { composingText += char }
            } else {
                let context = getContextBefore()
                if let last = context.last, let next = dakutenCycle[last] {
                    onBackspace(); onInsert(String(next))
                } else { composingText += char }
            }
        } else if isHiragana(char) {
            composingText += char
        } else {
            if !composingText.isEmpty { onInsert(composingText); composingText = "" }
            onInsert(char)
        }
    }
}
