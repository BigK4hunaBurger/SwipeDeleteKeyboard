import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("キーボードの有効化") {
                    step(n: 1, text: "設定 → 一般 → キーボード → キーボードを追加")
                    step(n: 2, text: "「SwipeDeleteKeyboard」を選んで追加")
                    step(n: 3, text: "キーボード一覧で「フルアクセスを許可」をオン")
                }
                Section("使い方") {
                    Label("バックスペース長押し → 左にスライド → 離して一括削除", systemImage: "hand.draw")
                    Label("「JP / EN」ボタンで言語切り替え", systemImage: "character.bubble")
                    Label("日本語モード: ローマ字入力でひらがな変換", systemImage: "a.circle")
                    Label("地球儀ボタンで他のキーボードに切り替え", systemImage: "globe")
                }
            }
            .navigationTitle("SwipeDelete Keyboard")
        }
    }

    private func step(n: Int, text: String) -> some View {
        Label(text, systemImage: "\(n).circle.fill")
    }
}

#Preview { ContentView() }
