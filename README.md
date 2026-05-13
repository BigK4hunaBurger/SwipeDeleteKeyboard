# SwipeDelete Keyboard

バックスペース長押し + 左スライドで削除範囲を選択、離して一括削除するiOSカスタムキーボード。

## ファイル構成

```
App/
  SwipeDeleteKeyboardApp.swift   — アプリエントリーポイント
  ContentView.swift              — 使い方説明画面

KeyboardExtension/
  KeyboardViewController.swift  — UIInputViewController（UIKit→SwiftUI橋渡し）
  KeyboardView.swift             — キーボードUI (SwiftUI, #Preview対応)
  BackspaceGestureView.swift     — 長押し+スライドジェスチャー (UIKit)
  JapaneseConverter.swift        — ローマ字→ひらがな変換
```

## Xcodeでのセットアップ（Mac必須）

1. Xcodeで新規プロジェクト作成
   - Template: **App**
   - Product Name: `SwipeDeleteKeyboard`
   - Bundle ID: `com.yourname.swipedelete`
   - Language: Swift / SwiftUI

2. Keyboard Extension を追加
   - File → New → Target → **Custom Keyboard Extension**
   - Product Name: `KeyboardExtension`
   - Bundle ID: `com.yourname.swipedelete.KeyboardExtension`

3. このリポジトリのファイルをXcodeにドラッグ
   - `App/` 内のファイル → メインターゲットに追加
   - `KeyboardExtension/` 内のファイル → KeyboardExtensionターゲットに追加

4. Info.plist (KeyboardExtension) に追記
   ```xml
   <key>NSExtension</key>
   <dict>
     <key>NSExtensionAttributes</key>
     <dict>
       <key>IsASCIICapable</key><false/>
       <key>PrefersRightToLeft</key><false/>
       <key>PrimaryLanguage</key><string>en-US</string>
       <key>RequestsOpenAccess</key><false/>
     </dict>
     <key>NSExtensionPointIdentifier</key>
     <string>com.apple.keyboard-input-mode</string>
     <key>NSExtensionPrincipalClass</key>
     <string>$(PRODUCT_MODULE_NAME).KeyboardViewController</string>
   </dict>
   ```

5. Deployment Target を **iOS 16.0** 以上に設定（両ターゲット）

## SwiftUI Preview で確認

`KeyboardView.swift` を Xcode で開くと `#Preview` ブロックで即確認できます。
バックスペースのスライドジェスチャーはシミュレーター/実機でのみ動作します。

## Codemagic でビルド（Mac不要）

1. GitHub に push
2. [codemagic.io](https://codemagic.io) でリポジトリを接続
3. iOS App ワークフローを設定（Xcode 16 / iOS 16+）
4. Apple Developer の証明書・プロビジョニングプロファイルをアップロード
5. ビルド → TestFlight に自動配布

## 操作方法

| 操作 | 動作 |
|------|------|
| キーをタップ | 文字入力 |
| `⇧` タップ | 大文字/小文字切り替え |
| `JP / EN` タップ | 日本語/英語モード切り替え |
| `⌫` タップ | 1文字削除 |
| `⌫` 長押し → 左スライド | 削除文字数選択（赤いインジケーターで表示） |
| `⌫` スライド後に離す | 選択した文字数を一括削除 |
| 🌐 タップ | 次のキーボードに切り替え |

## 日本語入力

ローマ字入力でひらがなに自動変換されます。
- `ka` → `か`
- `shi` → `し`
- `tsu` → `つ`
- `nn` → `ん`

漢字変換は非対応（ひらがな・カタカナのみ）。
