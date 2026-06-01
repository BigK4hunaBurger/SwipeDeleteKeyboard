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
    private let threshold: CGFloat = 14

    private var displayed: String {
        chars.char(for: dir) ?? chars.center
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(isActive ? Color(UIColor.systemGray2) : Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)

            VStack(spacing: 0) {
                if isActive && dir != .center {
                    Text(displayed)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.accentColor)
                } else {
                    Text(chars.center)
                        .font(.system(size: 17))
                        .foregroundColor(Color(UIColor.label))
                    HStack(spacing: 2) {
                        Text(chars.left  ?? " ").font(.system(size: 7))
                        Text(chars.up    ?? " ").font(.system(size: 7))
                        Text(chars.right ?? " ").font(.system(size: 7))
                    }
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 45)
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { v in
                    isActive = true
                    let dx = v.translation.width, dy = v.translation.height
                    if abs(dx) < threshold && abs(dy) < threshold { dir = .center }
                    else if abs(dx) > abs(dy) { dir = dx > 0 ? .right : .left }
                    else { dir = dy < 0 ? .up : .down }
                }
                .onEnded { v in
                    let dx = v.translation.width, dy = v.translation.height
                    let finalDir: FlickDirection
                    if abs(dx) < threshold && abs(dy) < threshold { finalDir = .center }
                    else if abs(dx) > abs(dy) { finalDir = dx > 0 ? .right : .left }
                    else { finalDir = dy < 0 ? .up : .down }
                    onSelect(chars.char(for: finalDir) ?? chars.center)
                    isActive = false; dir = .center
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
    // Composing state
    @State private var composingText = ""
    @State private var candidates: [String] = []

    private let kanaGrid: [[FlickChars]] = [
        [FlickChars("あ", up:"い", right:"う", down:"え", left:"お"),
         FlickChars("か", up:"き", right:"く", down:"け", left:"こ"),
         FlickChars("さ", up:"し", right:"す", down:"せ", left:"そ")],
        [FlickChars("た", up:"ち", right:"つ", down:"て", left:"と"),
         FlickChars("な", up:"に", right:"ぬ", down:"ね", left:"の"),
         FlickChars("は", up:"ひ", right:"ふ", down:"へ", left:"ほ")],
        [FlickChars("ま", up:"み", right:"む", down:"め", left:"も"),
         FlickChars("や", up:"（", right:"ゆ", down:"）", left:"よ"),
         FlickChars("ら", up:"り", right:"る", down:"れ", left:"ろ")],
        [FlickChars("、", up:"。", right:"？", down:"！", left:"・"),
         FlickChars("わ", up:"ゐ", right:"ん", down:"ー", left:"を"),
         FlickChars("゛", up:"ゃ", right:"っ", down:"ょ", left:"ゅ")],
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
                VStack(spacing: 3) {
                    ForEach(kanaGrid.indices, id: \.self) { row in
                        HStack(spacing: 3) {
                            ForEach(kanaGrid[row].indices, id: \.self) { col in
                                let chars = kanaGrid[row][col]
                                FlickKey(chars: chars) { char in
                                    handleSelect(char, fromKey: chars)
                                }
                            }
                        }
                    }
                }
                .padding(.leading, 3)

                VStack(spacing: 3) {
                    backspaceKey.frame(height: 45)
                    spaceKey.frame(height: 45)
                    returnKey.frame(height: 45)
                    switchKey.frame(height: 45)
                }
                .padding(.horizontal, 3)
                .frame(width: 72)
            }
            .padding(.vertical, 3)
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
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(4)
                .underline()

            Spacer()

            Button(action: {
                let text = composingText
                let results = KanjiConverter.shared.candidates(for: text)
                candidates = results
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
                onInsert(composingText)
                composingText = ""
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
                // Cancel button
                Button(action: {
                    candidates = []
                }) {
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
                        onInsert(candidate)
                        composingText = ""
                        candidates = []
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
            .font(.system(size: 14))
            .lineLimit(1)
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
                    } else {
                        onBackspace()
                    }
                },
                onSlideDelete: { count in
                    if !composingText.isEmpty {
                        composingText = ""
                        candidates = []
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
                let text = composingText
                candidates = KanjiConverter.shared.candidates(for: text)
            } else {
                onInsert("　")  // full-width space for Japanese
            }
        }) {
            Text(composingText.isEmpty ? "空白" : "変換")
                .font(.system(size: 13))
                .foregroundColor(Color(UIColor.label))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(composingText.isEmpty ? Color(UIColor.systemBackground) : Color.accentColor.opacity(0.15))
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    private var returnKey: some View {
        Button(action: {
            if !composingText.isEmpty {
                onInsert(composingText)
                composingText = ""
                candidates = []
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
            if !composingText.isEmpty {
                onInsert(composingText)
                composingText = ""
                candidates = []
            }
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

    private func handleSelect(_ char: String, fromKey chars: FlickChars) {
        candidates = []  // reset candidates on any new input
        if chars.center == "゛" {
            if !composingText.isEmpty {
                // Apply dakuten to last char in composing buffer
                if let last = composingText.last, let next = dakutenCycle[last] {
                    composingText = String(composingText.dropLast()) + String(next)
                } else {
                    composingText += char
                }
            } else {
                // Apply to last char in text field
                let context = getContextBefore()
                if let last = context.last, let next = dakutenCycle[last] {
                    onBackspace(); onInsert(String(next))
                } else {
                    composingText += char
                }
            }
        } else if char == "、" || char == "。" || char == "？" || char == "！" || char == "・" || char == "（" || char == "）" {
            // Punctuation: commit composing first, then insert
            if !composingText.isEmpty {
                onInsert(composingText)
                composingText = ""
            }
            onInsert(char)
        } else {
            composingText += char
        }
    }
}
