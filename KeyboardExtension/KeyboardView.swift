import SwiftUI

enum InputMode { case english, romajiJapanese, flickJapanese }

struct KeyboardView: View {
    let onInsert: (String) -> Void
    let onBackspace: () -> Void
    let onBackspaceSlide: (Int) -> Void
    let onReturn: () -> Void
    let onNextKeyboard: () -> Void
    let getContextBefore: () -> String

    @State private var mode: InputMode = .english
    @State private var isUppercase = false
    @State private var slideCount = 0
    @State private var contextBefore = ""
    @State private var pendingRomaji = ""

    private let converter = JapaneseConverter()

    private let rows: [[String]] = [
        ["q","w","e","r","t","y","u","i","o","p"],
        ["a","s","d","f","g","h","j","k","l"],
        ["z","x","c","v","b","n","m"]
    ]

    var body: some View {
        if mode == .flickJapanese {
            FlickKeyboardView(
                onInsert: onInsert,
                onBackspace: onBackspace,
                onBackspaceSlide: onBackspaceSlide,
                onReturn: onReturn,
                onSwitchToEnglish: { mode = .english },
                getContextBefore: getContextBefore
            )
        } else {
            qwertyKeyboard
        }
    }

    // MARK: - QWERTY layout

    private var qwertyKeyboard: some View {
        VStack(spacing: 0) {
            topBar

            ForEach(rows.indices, id: \.self) { row in
                HStack(spacing: 5) {
                    if row == 2 { shiftKey }
                    ForEach(rows[row], id: \.self) { key in
                        letterKey(key)
                    }
                    if row == 2 { backspaceKey }
                }
                .padding(.horizontal, 3)
                .padding(.vertical, 3)
            }

            HStack(spacing: 5) {
                nextKeyboardButton
                langToggleButton
                spaceKey
                returnKey
            }
            .padding(.horizontal, 3)
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
        if slideCount > 0 {
            deletionPreview
        } else if mode == .romajiJapanese && !pendingRomaji.isEmpty {
            romajiHint
        } else {
            Color.clear.frame(height: 28)
        }
    }

    private var deletionPreview: some View {
        let chars = Array(contextBefore)
        let del = min(slideCount, chars.count)
        let keepText = String(String(chars.prefix(chars.count - del)).suffix(20))
        let delText = String(String(chars.suffix(del)).suffix(20))

        return HStack(spacing: 0) {
            Spacer(minLength: 8)
            HStack(spacing: 0) {
                if !keepText.isEmpty {
                    Text(keepText).foregroundColor(Color(UIColor.label))
                }
                if !delText.isEmpty {
                    Text(delText).foregroundColor(.white).background(Color.red)
                }
                Text("｜").foregroundColor(Color(UIColor.label))
            }
            .font(.system(size: 14))
            .lineLimit(1)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(6)
            Spacer(minLength: 8)
        }
        .frame(height: 28)
        .padding(.top, 4)
    }

    private var romajiHint: some View {
        HStack {
            Spacer()
            Text(pendingRomaji)
                .font(.caption)
                .foregroundColor(Color(UIColor.secondaryLabel))
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Color(UIColor.systemBackground))
                .clipShape(Capsule())
            Spacer()
        }
        .frame(height: 28)
        .padding(.top, 4)
    }

    // MARK: - Keys

    private func letterKey(_ key: String) -> some View {
        let label = isUppercase ? key.uppercased() : key
        return Button(action: { handleLetter(key) }) {
            Text(label)
                .font(.system(size: 17))
                .foregroundColor(Color(UIColor.label))
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    private var shiftKey: some View {
        Button(action: { isUppercase.toggle() }) {
            Image(systemName: isUppercase ? "shift.fill" : "shift")
                .font(.system(size: 16))
                .foregroundColor(isUppercase ? .white : Color(UIColor.label))
                .frame(width: 42, height: 42)
                .background(isUppercase ? Color.accentColor : Color(UIColor.systemGray3))
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    private var backspaceKey: some View {
        ZStack {
            Image(systemName: "delete.left")
                .font(.system(size: 16))
                .foregroundColor(slideCount > 0 ? .red : Color(UIColor.label))
                .frame(width: 42, height: 42)
                .background(slideCount > 0 ? Color.red.opacity(0.15) : Color(UIColor.systemGray3))
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
                .allowsHitTesting(false)
            BackspaceButton(
                onTap: handleBackspace,
                onSlideDelete: { count in
                    withAnimation(.easeOut(duration: 0.1)) { slideCount = 0 }
                    onBackspaceSlide(count)
                    if mode == .romajiJapanese {
                        converter.flush(); pendingRomaji = ""
                    }
                },
                onCountChange: { count in
                    withAnimation(.easeInOut(duration: 0.1)) { slideCount = count }
                }
            )
        }
        .frame(width: 42, height: 42)
    }

    private var spaceKey: some View {
        Button(action: { handleSpace() }) {
            Text(mode == .romajiJapanese ? "スペース" : "space")
                .font(.system(size: 15))
                .foregroundColor(Color(UIColor.label))
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    private var returnKey: some View {
        Button(action: { flushJapanese(); onReturn() }) {
            Text("return")
                .font(.system(size: 15))
                .foregroundColor(Color(UIColor.label))
                .frame(width: 88, height: 42)
                .background(Color(UIColor.systemGray3))
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    private var nextKeyboardButton: some View {
        Button(action: { flushJapanese(); onNextKeyboard() }) {
            Image(systemName: "globe")
                .font(.system(size: 18))
                .foregroundColor(Color(UIColor.label))
                .frame(width: 42, height: 42)
                .background(Color(UIColor.systemGray3))
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    private var langToggleButton: some View {
        let label: String
        switch mode {
        case .english:        label = "あ"
        case .romajiJapanese: label = "フリック"
        case .flickJapanese:  label = "EN"
        }
        return Button(action: {
            flushJapanese()
            switch mode {
            case .english:        mode = .romajiJapanese
            case .romajiJapanese: mode = .flickJapanese
            case .flickJapanese:  mode = .english
            }
        }) {
            Text(label)
                .font(.system(size: label.count > 2 ? 11 : 14, weight: .semibold))
                .foregroundColor(Color(UIColor.label))
                .frame(width: 42, height: 42)
                .background(mode == .english ? Color(UIColor.systemGray3) : Color.accentColor.opacity(0.2))
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.25), radius: 0, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Input handling

    private func handleLetter(_ key: String) {
        let char = isUppercase ? key.uppercased() : key
        if isUppercase { isUppercase = false }

        switch mode {
        case .english:
            onInsert(char)
        case .romajiJapanese:
            let committed = converter.input(char)
            pendingRomaji = converter.pending
            if !committed.isEmpty { onInsert(committed) }
        case .flickJapanese:
            onInsert(char) // shouldn't reach here
        }
    }

    private func handleBackspace() {
        if mode == .romajiJapanese && converter.deleteFromBuffer() {
            pendingRomaji = converter.pending
            return
        }
        onBackspace()
    }

    private func handleSpace() {
        flushJapanese()
        onInsert(mode == .romajiJapanese ? "　" : " ")
    }

    private func flushJapanese() {
        guard mode == .romajiJapanese else { return }
        let result = converter.flush()
        pendingRomaji = ""
        if !result.isEmpty { onInsert(result) }
    }
}

// MARK: - Preview

#Preview {
    KeyboardView(
        onInsert: { print("insert: \($0)") },
        onBackspace: { print("backspace") },
        onBackspaceSlide: { print("slide delete: \($0)") },
        onReturn: { print("return") },
        onNextKeyboard: { print("next keyboard") },
        getContextBefore: { "これはテスト文章です" }
    )
    .frame(height: 280)
}
