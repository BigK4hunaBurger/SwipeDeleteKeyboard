import SwiftUI

// MARK: - Flick data types

enum FlickDirection { case center, up, right, down, left }

struct FlickChars {
    let center: String
    let up: String?
    let right: String?
    let down: String?
    let left: String?

    init(_ center: String, up: String? = nil, right: String? = nil,
         down: String? = nil, left: String? = nil) {
        self.center = center; self.up = up; self.right = right
        self.down = down; self.left = left
    }

    func char(for dir: FlickDirection) -> String? {
        switch dir {
        case .center: return center
        case .up:     return up
        case .right:  return right
        case .down:   return down
        case .left:   return left
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

    private var selectedChar: String {
        chars.char(for: dir) ?? chars.center
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(isActive ? Color(UIColor.systemGray3) : Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.3), radius: 0, x: 0, y: 1)

            if isFlicking {
                Text(selectedChar)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.accentColor)
            } else {
                // Cross-shaped hint layout
                VStack(spacing: 1) {
                    Text(chars.up ?? " ")
                        .font(.system(size: 9))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                    HStack(spacing: 1) {
                        Text(chars.left ?? " ")
                            .font(.system(size: 9))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                            .frame(width: 12)
                        Text(chars.center)
                            .font(.system(size: 18))
                            .foregroundColor(Color(UIColor.label))
                            .frame(minWidth: 18)
                        Text(chars.right ?? " ")
                            .font(.system(size: 9))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                            .frame(width: 12)
                    }
                    Text(chars.down ?? " ")
                        .font(.system(size: 9))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 46)
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
                        isFlicking = false
                        dir = .center
                    }
                }
                .onEnded { v in
                    let dx = v.translation.width, dy = v.translation.height
                    let dist = sqrt(dx * dx + dy * dy)
                    let finalDir: FlickDirection
                    if dist < threshold {
                        finalDir = .center
                    } else if abs(dx) > abs(dy) {
                        finalDir = dx > 0 ? .right : .left
                    } else {
                        finalDir = dy < 0 ? .up : .down
                    }
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
    let getContextBefore: () -> String

    @State private var slideCount = 0
    @State private var contextBefore = ""
    @State private var composingText = ""
    @State private var candidates: [String] = []

    // Standard Japanese flick: left=い/き/し..., up=う/く/す..., right=え/け/せ..., down=お/こ/そ...
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
            for (i, ch) in cycle.enumerated() {
                m[ch] = cycle[(i + 1) % cycle.count]
            }
        }
        return m
    }()

    var body: some View {
        VStack(spacing: 0) {
            topBar

            HStack(alignment: .top, spacing: 0) {
                VStack(spacing: 4) {
                    ForEach(kanaGrid.indices, id: \.self) { row in
                        HStack(spacing: 4) {
                            ForEach(kanaGrid[row].indices, id: \.self) { col in
                                let chars = kanaGrid[row][col]
                                FlickKey(chars: chars) { char in
                                    handleSelect(char, fromKey: chars)
                                }
                            }
                        }
                    }
                }
                .padding(.leading, 8)  // 左端余白

                VStack(spacing: 4) {
                    backspaceKey.frame(height: 46)
                    spaceKey.frame(height: 46)
                    returnKey.frame(height: 46)
                    switchKey.frame(height: 46)
                }
                .padding(.leading, 4)
                .padding(.trailing, 8)  // 右端余白
                .frame(width: 76)
            }
            .padding(.vertical, 4)
        }
        .background(Color(UIColor.systemGray5))
        .onChange(of: slideCount) { newCount in
            if newCount > 0 { contextBefore = getContextBefore() }
        }
    }

    // MARK: - Top bar

    @ViewBuilder
    private var topBar: some View {
        if !candidates.isEmpty {
            candidateBar
        } else if !composingText.isEmpty {
            composingBar
        } else if slideCount > 0 {
            deletionPreview
        } else {
            Color.clear.frame(height: 44)
        }
    }

    private var composingBar: some View {
        HStack(spacing: 8) {
            Text(composingText)
                .font(.system(size: 16))
                .foregroundColor(Color(UIColor.label))
                .underline()
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(4)

            Spacer()

            Button(action: {
                let t = composingText
                candidates = KanjiConverter.shared.candidates(for: t)
            }) {
                Text("変換")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color.accentColor)
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)

            Button(action: {
                onInsert(composingText); composingText = ""
            }) {
                Text("確定")
                    .font(.system(size: 14))
                    .foregroundColor(Color(UIColor.label))
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color(UIColor.systemGray3))
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .frame(height: 44)
        .background(Color(UIColor.systemGray6))
    }

    private var candidateBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                Button(action: { candidates = [] }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .padding(8)
                        .background(Color(UIColor.systemGray4))
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)

                ForEach(candidates, id: \.self) { candidate in
                    Button(action: {
                        onInsert(candidate); composingText = ""; candidates = []
                    }) {
                        Text(candidate)
                            .font(.system(size: 16))
                            .foregroundColor(Color(UIColor.label))
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 44)
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
            .font(.system(size: 14)).lineLimit(1)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(6)
            Spacer(minLength: 8)
        }
        .frame(height: 44)
        .background(Color(UIColor.systemGray6))
    }

    // MARK: - Function keys

    private var backspaceKey: some View {
        ZStack {
            Image(systemName: "delete.left")
                .font(.system(size: 16))
                .foregroundColor(slideCount > 0 ? .red : Color(UIColor.label))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(slideCount > 0 ? Color.red.opacity(0.15) : Color(UIColor.systemGray3))
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
                .allowsHitTesting(false)
            BackspaceButton(
                onTap: {
                    if !composingText.isEmpty {
                        candidates = []
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
                let t = composingText
                candidates = KanjiConverter.shared.candidates(for: t)
            } else { onInsert("　") }
        }) {
            Text(composingText.isEmpty ? "空白" : "変換")
                .font(.system(size: 13))
                .foregroundColor(Color(UIColor.label))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(composingText.isEmpty ? Color(UIColor.systemBackground) : Color.accentColor.opacity(0.2))
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
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
            Text("改行")
                .font(.system(size: 13))
                .foregroundColor(Color(UIColor.label))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemGray3))
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    private var switchKey: some View {
        Button(action: {
            if !composingText.isEmpty { onInsert(composingText); composingText = ""; candidates = [] }
            onSwitchToEnglish()
        }) {
            Text("ABC")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(UIColor.label))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemGray3))
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Input handling

    private func isHiragana(_ str: String) -> Bool {
        guard let s = str.unicodeScalars.first else { return false }
        return s.value >= 0x3041 && s.value <= 0x3096
    }

    private func handleSelect(_ char: String, fromKey chars: FlickChars) {
        candidates = []
        if chars.center == "゛" {
            if !composingText.isEmpty {
                if let last = composingText.last, let next = dakutenCycle[last] {
                    composingText = String(composingText.dropLast()) + String(next)
                } else {
                    composingText += char
                }
            } else {
                let context = getContextBefore()
                if let last = context.last, let next = dakutenCycle[last] {
                    onBackspace(); onInsert(String(next))
                } else {
                    composingText += char
                }
            }
        } else if isHiragana(char) {
            composingText += char
        } else {
            // 句読点・記号は即確定
            if !composingText.isEmpty {
                onInsert(composingText); composingText = ""
            }
            onInsert(char)
        }
    }
}
