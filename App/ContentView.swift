import SwiftUI

// キーボード拡張の KeyboardTheme と対応するテーマ定義
enum KBTheme: String, CaseIterable, Identifiable {
    case system, terminal, neon, sakura, midnight, paper, sunset
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:   return "System"
        case .terminal: return "Terminal >_"
        case .neon:     return "Neon ◈"
        case .sakura:   return "Sakura ❀"
        case .midnight: return "Midnight ☾"
        case .paper:    return "Paper ▢"
        case .sunset:   return "Sunset ◐"
        }
    }

    var subtitle: String {
        switch self {
        case .system:   return "標準 iOS スタイル(ライト/ダーク自動)"
        case .terminal: return "黒背景・緑モノスペース・コマンドプロンプト風"
        case .neon:     return "暗紫背景・シアン/マゼンタ・グロー"
        case .sakura:   return "淡いピンク・丸キー・やわらかい印象"
        case .midnight: return "深い紺・アイスブルー・落ち着いたダーク"
        case .paper:    return "生成り×黒・直線的・ミニマル"
        case .sunset:   return "ダークブラウン×オレンジ・あたたかいダーク"
        }
    }

    var previewBg: Color {
        switch self {
        case .system:   return Color(UIColor.systemBackground)
        case .terminal: return Color(red: 0.04, green: 0.05, blue: 0.04)
        case .neon:     return Color(red: 0.06, green: 0.05, blue: 0.14)
        case .sakura:   return Color(red: 0.99, green: 0.93, blue: 0.95)
        case .midnight: return Color(red: 0.04, green: 0.06, blue: 0.12)
        case .paper:    return Color(red: 0.96, green: 0.95, blue: 0.93)
        case .sunset:   return Color(red: 0.14, green: 0.07, blue: 0.09)
        }
    }

    var previewKey: Color {
        switch self {
        case .system:   return Color(UIColor.secondarySystemBackground)
        case .terminal: return Color(red: 0.09, green: 0.11, blue: 0.09)
        case .neon:     return Color(red: 0.12, green: 0.10, blue: 0.24)
        case .sakura:   return .white
        case .midnight: return Color(red: 0.09, green: 0.13, blue: 0.22)
        case .paper:    return .white
        case .sunset:   return Color(red: 0.24, green: 0.13, blue: 0.15)
        }
    }

    var previewFg: Color {
        switch self {
        case .system:   return Color(UIColor.label)
        case .terminal: return Color(red: 0.0, green: 0.9, blue: 0.27)
        case .neon:     return Color(red: 0.0, green: 0.96, blue: 1.0)
        case .sakura:   return Color(red: 0.35, green: 0.20, blue: 0.25)
        case .midnight: return Color(red: 0.75, green: 0.84, blue: 0.98)
        case .paper:    return Color(red: 0.12, green: 0.12, blue: 0.11)
        case .sunset:   return Color(red: 1.0, green: 0.84, blue: 0.70)
        }
    }

    var usesMonospaced: Bool { self == .terminal }
}

private let sharedUD = UserDefaults(suiteName: "group.com.bigk4huna.swipedelete") ?? .standard

struct ContentView: View {
    @State private var selectedTheme: KBTheme = {
        KBTheme(rawValue: sharedUD.string(forKey: "kbTheme") ?? "") ?? .system
    }()
    @State private var japaneseLayout: Bool = {
        if let v = sharedUD.object(forKey: "kbLayoutJapanese") as? Bool { return v }
        if let v = UserDefaults.standard.object(forKey: "kbLayoutJapanese") as? Bool { return v }
        return true
    }()

    var body: some View {
        NavigationStack {
            List {
                setupSection
                usageSection
                layoutSection
                themeSection
            }
            .navigationTitle("SwipeDelete Keyboard")
        }
    }

    // MARK: - Sections

    private var setupSection: some View {
        Section("キーボードの有効化") {
            step(n: 1, text: "設定 → 一般 → キーボード → キーボードを追加")
            step(n: 2, text: "「SwipeDelete Keyboard」を選んで追加")
        }
    }

    private var usageSection: some View {
        Section("使い方") {
            Label("純正と同じフリック入力(上下左右で各文字)", systemImage: "arrow.up.and.down.and.arrow.left.and.right")
            Label("⌫ を押したまま左へスライド → 削除範囲を選んで一括削除", systemImage: "hand.draw")
            Label("⌫ 長押しで連続削除(だんだん加速)", systemImage: "delete.left")
            Label("空白キーを左右にスライドでカーソル移動", systemImage: "cursorarrow.motionlines")
            Label("小゛゜タップで 小文字 → 濁点 → 半濁点 を循環", systemImage: "textformat.alt")
            Label("⤺ で直前の入力/削除を取り消し", systemImage: "arrow.uturn.backward")
        }
    }

    private var layoutSection: some View {
        Section {
            Toggle(isOn: $japaneseLayout) {
                Label("日本語フリック入力", systemImage: "character.ja")
            }
            .onChange(of: japaneseLayout) { newValue in
                sharedUD.set(newValue, forKey: "kbLayoutJapanese")
                UserDefaults.standard.set(newValue, forKey: "kbLayoutJapanese")
            }
        } header: {
            Text("言語")
        } footer: {
            Text(japaneseLayout
                 ? "かな入力・漢字変換・候補バーが有効になります。"
                 : "英数字のみの12キー配列になります。")
                .font(.caption)
        }
    }

    private var themeSection: some View {
        Section {
            ForEach(KBTheme.allCases) { theme in
                ThemeRow(theme: theme, isSelected: selectedTheme == theme) {
                    selectedTheme = theme
                    sharedUD.set(theme.rawValue, forKey: "kbTheme")
                }
            }
        } header: {
            Text("テーマ")
        } footer: {
            Text("変更は次回キーボードを開いた時に反映されます。キーボード上の ⤺ キーを長押しすると、その場でもテーマを順番に切り替えられます。")
                .font(.caption)
        }
    }

    // MARK: - Helpers

    private func step(n: Int, text: String) -> some View {
        Label(text, systemImage: "\(n).circle.fill")
    }
}

struct ThemeRow: View {
    let theme: KBTheme
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // ミニキーボードのプレビュー
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(theme.previewBg)
                    HStack(spacing: 3) {
                        ForEach(["あ", "か", "さ"], id: \.self) { ch in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(theme.previewKey)
                                .frame(width: 14, height: 18)
                                .overlay(
                                    Text(ch)
                                        .font(theme.usesMonospaced
                                              ? .system(size: 9, weight: .semibold, design: .monospaced)
                                              : .system(size: 9, weight: .semibold))
                                        .foregroundColor(theme.previewFg)
                                )
                        }
                    }
                }
                .frame(width: 64, height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color(UIColor.separator), lineWidth: 0.5)
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.displayName)
                        .font(.body)
                        .foregroundColor(Color(UIColor.label))
                    Text(theme.subtitle)
                        .font(.caption)
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                        .fontWeight(.semibold)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview { ContentView() }
