import SwiftUI

// MARK: - Models

enum AppLang: String, CaseIterable {
    case ja = "JA", en = "EN"
    static var detected: AppLang {
        Locale.current.language.languageCode?.identifier == "ja" ? .ja : .en
    }
}

enum KBTheme: String, CaseIterable, Identifiable {
    case system, terminal, neon, sakura, midnight, paper, sunset, wood, metal, ice
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:   return "System"
        case .terminal: return "Terminal"
        case .neon:     return "Neon"
        case .sakura:   return "Sakura"
        case .midnight: return "Midnight"
        case .paper:    return "Paper"
        case .sunset:   return "Sunset"
        case .wood:     return "Wood"
        case .metal:    return "Metal"
        case .ice:      return "Ice"
        }
    }

    var accentColor: Color {
        switch self {
        case .system:   return Color(UIColor.label)
        case .terminal: return Color(red: 0,    green: 0.90, blue: 0.27)
        case .neon:     return Color(red: 1.00, green: 0.27, blue: 0.78)
        case .sakura:   return Color(red: 0.85, green: 0.35, blue: 0.54)
        case .midnight: return Color(red: 0.43, green: 0.67, blue: 1.00)
        case .paper:    return Color(red: 0.16, green: 0.16, blue: 0.15)
        case .sunset:   return Color(red: 0.94, green: 0.39, blue: 0.24)
        case .wood:     return Color(red: 0.62, green: 0.38, blue: 0.14)
        case .metal:    return Color(red: 0.54, green: 0.58, blue: 0.64)
        case .ice:      return Color(red: 0.29, green: 0.54, blue: 0.86)
        }
    }
}

// MARK: - ContentView

struct ContentView: View {
    @State private var lang: AppLang = .detected

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                headerView
                setupSection
                featuresSection
                themeSection
                Spacer(minLength: 40)
            }
            .padding(24)
        }
    }

    // MARK: Header

    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Wipe")
                    .font(.system(size: 48, weight: .black))
                Text(lang == .ja
                     ? "スライドで消せるキーボード"
                     : "The keyboard that swipes to delete")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            langToggle
        }
    }

    private var langToggle: some View {
        HStack(spacing: 0) {
            ForEach(AppLang.allCases, id: \.rawValue) { l in
                Button(action: { lang = l }) {
                    Text(l.rawValue)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(lang == l
                            ? Color(UIColor.systemBackground)
                            : .primary)
                        .frame(width: 36, height: 30)
                        .background(lang == l ? Color.primary : Color.clear)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.primary, lineWidth: 1.5))
    }

    // MARK: Setup

    private var setupSection: some View {
        section(title: lang == .ja ? "セットアップ" : "SETUP") {
            VStack(alignment: .leading, spacing: 16) {
                setupRow(1, lang == .ja
                    ? "設定 → 一般 → キーボード → キーボードを追加"
                    : "Settings → General → Keyboard → Add New Keyboard")
                setupRow(2, lang == .ja
                    ? "「Wipe Japanese」または「Wipe English」を選択"
                    : "Select \"Wipe Japanese\" or \"Wipe English\"")
                setupRow(3, lang == .ja
                    ? "フルアクセスを許可"
                    : "Tap \"Allow Full Access\"")
            }
        }
    }

    private func setupRow(_ n: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text("\(n)")
                .font(.system(size: 11, weight: .black))
                .frame(width: 22, height: 22)
                .background(Color.primary)
                .foregroundColor(Color(UIColor.systemBackground))
                .clipShape(Circle())
            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Features

    private var featuresSection: some View {
        section(title: lang == .ja ? "使い方" : "HOW TO USE") {
            VStack(alignment: .leading, spacing: 12) {
                featureRow("⌫ + ←",
                    lang == .ja ? "範囲を選んで一括削除" : "Swipe to select and batch-delete")
                featureRow("⌫  長押し",
                    lang == .ja ? "連続削除（だんだん加速）" : "Hold to delete continuously")
                featureRow("space ←→",
                    lang == .ja ? "カーソル移動" : "Slide to move cursor")
                featureRow("⤺",
                    lang == .ja ? "入力・削除を取り消し" : "Undo last input or deletion")
                featureRow("小゛゜",
                    lang == .ja ? "小文字／濁点／半濁点を循環" : "Cycle small / voiced / semi-voiced")
                featureRow("◑",
                    lang == .ja ? "テーマをキーボード内で変更" : "Change theme inside the keyboard")
            }
        }
    }

    private func featureRow(_ key: String, _ desc: String) -> some View {
        HStack(alignment: .top, spacing: 0) {
            Text(key)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .frame(width: 94, alignment: .leading)
            Text(desc)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Theme

    private var themeSection: some View {
        section(title: "THEME") {
            VStack(alignment: .leading, spacing: 12) {
                Text(lang == .ja
                     ? "キーボード内の ◑ ボタンからテーマを切り替えられます。"
                     : "Tap ◑ inside the keyboard to cycle through themes.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                let cols = [GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: cols, spacing: 8) {
                    ForEach(KBTheme.allCases) { theme in
                        HStack(spacing: 9) {
                            Circle()
                                .fill(theme.accentColor)
                                .frame(width: 9, height: 9)
                            Text(theme.displayName)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 11)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(Color(UIColor.separator), lineWidth: 0.5)
                        )
                    }
                }
            }
        }
    }

    // MARK: Section helper

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                    .kerning(1.5)
                Rectangle()
                    .fill(Color(UIColor.separator))
                    .frame(height: 0.5)
            }
            content()
        }
    }
}

#Preview { ContentView() }
