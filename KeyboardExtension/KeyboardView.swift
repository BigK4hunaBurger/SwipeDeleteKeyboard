import SwiftUI

enum InputMode { case english, japanese }

struct KeyboardView: View {
    let onInsert: (String) -> Void
    let onBackspace: () -> Void
    let onBackspaceSlide: (Int) -> Void
    let onReturn: () -> Void
    let onNextKeyboard: () -> Void

    @State private var mode: InputMode = .english
    @State private var isUppercase = false
    @State private var slideCount = 0       // 0 = not in slide mode
    @State private var pendingRomaji = ""   // shown as grey hint in Japanese mode

    private let converter = JapaneseConverter()

    private let rows: [[String]] = [
        ["q","w","e","r","t","y","u","i","o","p"],
        ["a","s","d","f","g","h","j","k","l"],
        ["z","x","c","v","b","n","m"]
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Slide-delete indicator
            slideIndicator

            // Key rows
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

            // Bottom row
            HStack(spacing: 5) {
                nextKeyboardButton
                langToggleButton
                spaceKey
                returnKey
            }
            .padding(.horizontal, 3)
            .padding(.vertical, 3)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Slide indicator

    @ViewBuilder
    private var slideIndicator: some View {
        if slideCount > 0 {
            HStack {
                Spacer()
                Text("← \(slideCount)文字削除")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.85))
                    .clipShape(Capsule())
                Spacer()
            }
            .transition(.opacity)
            .padding(.top, 4)
        } else {
            // Show pending romaji in Japanese mode
            if mode == .japanese && !pendingRomaji.isEmpty {
                HStack {
                    Spacer()
                    Text(pendingRomaji)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                    Spacer()
                }
                .padding(.top, 4)
            } else {
                Color.clear.frame(height: 26)
            }
        }
    }

    // MARK: - Keys

    private func letterKey(_ key: String) -> some View {
        let label = isUppercase ? key.uppercased() : key
        return Button(action: { handleLetter(key) }) {
            Text(label)
                .font(.system(size: 17))
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(Color(.white))
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.15), radius: 0, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    private var shiftKey: some View {
        Button(action: { isUppercase.toggle() }) {
            Image(systemName: isUppercase ? "shift.fill" : "shift")
                .font(.system(size: 16))
                .frame(width: 42, height: 42)
                .background(isUppercase ? Color.accentColor : Color(.systemGray4))
                .foregroundColor(isUppercase ? .white : .primary)
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.15), radius: 0, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    private var backspaceKey: some View {
        ZStack {
            Image(systemName: "delete.left")
                .font(.system(size: 16))
                .foregroundColor(slideCount > 0 ? .red : .primary)
                .frame(width: 42, height: 42)
                .background(slideCount > 0 ? Color.red.opacity(0.15) : Color(.systemGray4))
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.15), radius: 0, x: 0, y: 1)
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
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(Color(.white))
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.15), radius: 0, x: 0, y: 1)
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
                .frame(width: 88, height: 42)
                .background(Color(.systemGray4))
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.15), radius: 0, x: 0, y: 1)
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
                .frame(width: 42, height: 42)
                .background(Color(.systemGray4))
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.15), radius: 0, x: 0, y: 1)
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
                .frame(width: 42, height: 42)
                .background(Color(.systemGray4))
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.15), radius: 0, x: 0, y: 1)
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

// MARK: - Preview

#Preview {
    KeyboardView(
        onInsert: { print("insert: \($0)") },
        onBackspace: { print("backspace") },
        onBackspaceSlide: { print("slide delete: \($0)") },
        onReturn: { print("return") },
        onNextKeyboard: { print("next keyboard") }
    )
    .frame(height: 260)
}
