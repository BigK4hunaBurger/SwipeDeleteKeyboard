import SwiftUI

enum InputMode { case english, japanese }

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
            if newCount > 0 {
                contextBefore = getContextBefore()
            }
        }
    }

    // MARK: - Top bar (deletion preview or romaji hint)

    @ViewBuilder
    private var topBar: some View {
        if slideCount > 0 {
            deletionPreview
        } else if mode == .japanese && !pendingRomaji.isEmpty {
            romajiHint
        } else {
            Color.clear.frame(height: 28)
        }
    }

    private var deletionPreview: some View {
        let context = contextBefore
        let totalChars = context.unicodeScalars.count
        let deleteCount = min(slideCount, totalChars)
        let keepCount = totalChars - deleteCount

        let keepText = String(context.unicodeScalars.prefix(keepCount)) ?? ""
        let deleteText = String(context.unicodeScalars.suffix(deleteCount)) ?? ""

        // Show at most last 40 chars to avoid overflow
        let displayKeep = String(keepText.suffix(40 - min(deleteCount, 20)))
        let displayDelete = String(deleteText.suffix(20))

        return HStack(spacing: 0) {
            Spacer(minLength: 8)
            HStack(spacing: 0) {
                if !displayKeep.isEmpty {
                    Text(displayKeep)
                        .foregroundColor(Color(UIColor.label))
                }
                if !displayDelete.isEmpty {
                    Text(displayDelete)
                        .foregroundColor(.white)
                        .background(Color.red)
                }
                Text("｜")
                    .foregroundColor(Color(UIColor.label))
            }
            .font(.system(size: 14))
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
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
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
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
                    if mode == .japanese {
                        converter.flush()
                        pendingRomaji = ""
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
            Text(mode == .japanese ? "スペース" : "space")
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
        Button(action: {
            flushJapanese()
            onReturn()
        }) {
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
        Button(action: {
            flushJapanese()
            onNextKeyboard()
        }) {
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
        Button(action: {
            flushJapanese()
            mode = mode == .english ? .japanese : .english
        }) {
            Text(mode == .english ? "JP" : "EN")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(UIColor.label))
                .frame(width: 42, height: 42)
                .background(Color(UIColor.systemGray3))
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
        case .japanese:
            let committed = converter.input(char)
            pendingRomaji = converter.pending
            if !committed.isEmpty { onInsert(committed) }
        }
    }

    private func handleBackspace() {
        if mode == .japanese && converter.deleteFromBuffer() {
            pendingRomaji = converter.pending
            return
        }
        onBackspace()
    }

    private func handleSpace() {
        flushJapanese()
        onInsert(" ")
    }

    private func flushJapanese() {
        guard mode == .japanese else { return }
        let result = converter.flush()
        pendingRomaji = ""
        if !result.isEmpty { onInsert(result) }
    }
}

private extension String {
    init?(_ scalars: Substring.UnicodeScalarView) {
        self.init(scalars)
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
