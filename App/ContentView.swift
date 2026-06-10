import SwiftUI

// Theme enum mirroring KeyboardTheme in the keyboard extension
enum KBTheme: String, CaseIterable, Identifiable {
    case system, terminal, neon
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:   return "System"
        case .terminal: return "Terminal >_"
        case .neon:     return "Neon ◈"
        }
    }

    var subtitle: String {
        switch self {
        case .system:   return "標準 iOS スタイル"
        case .terminal: return "黒背景・緑モノスペース・コマンドプロンプト風"
        case .neon:     return "暗紫背景・シアン/マゼンタ・グロー"
        }
    }

    var previewBg: Color {
        switch self {
        case .system:   return Color(UIColor.systemBackground)
        case .terminal: return Color(red: 0.07, green: 0.07, blue: 0.07)
        case .neon:     return Color(red: 0.06, green: 0.06, blue: 0.14)
        }
    }

    var previewFg: Color {
        switch self {
        case .system:   return Color(UIColor.label)
        case .terminal: return Color(red: 0.0, green: 0.9, blue: 0.2)
        case .neon:     return Color(red: 0.0, green: 1.0, blue: 1.0)
        }
    }
}

private let sharedUD = UserDefaults(suiteName: "group.com.bigk4huna.swipedelete") ?? .standard

struct ContentView: View {
    @State private var selectedTheme: KBTheme = {
        KBTheme(rawValue: sharedUD.string(forKey: "kbTheme") ?? "") ?? .system
    }()

    var body: some View {
        NavigationStack {
            List {
                setupSection
                usageSection
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
            step(n: 3, text: "キーボード一覧で「フルアクセスを許可」をオン")
        }
    }

    private var usageSection: some View {
        Section("使い方") {
            Label("上下左右フリックで各文字を入力", systemImage: "arrow.up.and.down.and.arrow.left.and.right")
            Label("バックスペース長押し → 左スライドで一括削除", systemImage: "hand.draw")
            Label("ABCボタンで英語キーボードに切り替え", systemImage: "character.bubble")
            Label("☆123ボタンで記号/数字モード", systemImage: "number")
            Label("地球儀ボタンで他のキーボードに切り替え", systemImage: "globe")
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
            Text("変更はキーボードを再起動した時に反映されます。キーボード内の左下ボタンからも切り替え可能。")
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
                // Color swatch
                RoundedRectangle(cornerRadius: 6)
                    .fill(theme.previewBg)
                    .frame(width: 44, height: 32)
                    .overlay(
                        HStack(spacing: 3) {
                            ForEach(["あ", "か", "さ"], id: \.self) { ch in
                                Text(ch)
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(theme.previewFg)
                            }
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
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
