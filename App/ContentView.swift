import SwiftUI

private let sharedUD = UserDefaults(suiteName: "group.com.bigk4huna.swipedelete") ?? .standard

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

    func name(_ lang: AppLang) -> String {
        switch self {
        case .system:   return lang == .ja ? "システム" : "System"
        case .terminal: return "Terminal"
        case .neon:     return "Neon"
        case .sakura:   return lang == .ja ? "サクラ" : "Sakura"
        case .midnight: return "Midnight"
        case .paper:    return lang == .ja ? "ペーパー" : "Paper"
        case .sunset:   return lang == .ja ? "サンセット" : "Sunset"
        case .wood:     return lang == .ja ? "ウッド" : "Wood"
        case .metal:    return "Metal"
        case .ice:      return lang == .ja ? "アイス" : "Ice"
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
    @State private var selectedTheme: KBTheme = {
        KBTheme(rawValue: sharedUD.string(forKey: "kbTheme") ?? "") ?? .system
    }()
    @State private var japaneseLayout: Bool = {
        if let v = sharedUD.object(forKey: "kbLayoutJapanese") as? Bool { return v }
        return true
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                headerView
                setupSection
                featuresSection
                themeSection
                settingsSection
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
                    lang == .ja ? "テーマ変更パネルを開く" : "Open theme picker")
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
        section(title: lang == .ja ? "テーマ" : "THEME") {
            let cols = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: cols, spacing: 8) {
                ForEach(KBTheme.allCases) { theme in
                    Button(action: {
                        selectedTheme = theme
                        sharedUD.set(theme.rawValue, forKey: "kbTheme")
                    }) {
                        HStack(spacing: 9) {
                            Circle()
                                .fill(theme.accentColor)
                                .frame(width: 9, height: 9)
                            Text(theme.name(lang))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedTheme == theme {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal, 11)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(
                                    selectedTheme == theme
                                        ? Color.primary
                                        : Color(UIColor.separator),
                                    lineWidth: selectedTheme == theme ? 1.5 : 0.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: Settings

    private var settingsSection: some View {
        section(title: lang == .ja ? "設定" : "SETTINGS") {
            Toggle(isOn: $japaneseLayout) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(lang == .ja ? "日本語フリック入力" : "Japanese Flick Input")
                        .font(.body)
                    Text(lang == .ja
                         ? "Wipe Japanese でかな・漢字変換を使用する"
                         : "Enable kana/kanji input in Wipe Japanese")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .tint(.primary)
            .onChange(of: japaneseLayout) { newValue in
                sharedUD.set(newValue, forKey: "kbLayoutJapanese")
                UserDefaults.standard.set(newValue, forKey: "kbLayoutJapanese")
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
