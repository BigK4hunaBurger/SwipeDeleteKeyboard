# App Store Connect 登録情報

## アプリ名
Wipe

## サブタイトル（30字以内）
**JA:** スライドで消せる日本語キーボード
**EN:** Delete smarter. Type faster.

## キーワード（100字以内）
keyboard,delete,swipe,japanese,flick,kana,kanji,type,productivity,theme

## プライバシーポリシー URL
https://bigk4hunaburger.github.io/SwipeDeleteKeyboard/privacy.html

---

## 説明文（日本語）

⌫ を押しながら左にスライドするだけ。消したい範囲をなぞって、まとめて削除。
Wipe は「範囲削除」を中心に設計した、新しいキーボードです。

【主な機能】

▸ 範囲削除（スライド削除）
⌫ キーを押したまま左にスライドすると、削除範囲がリアルタイムで赤くハイライト表示されます。指を離した瞬間に、選んだ文字をまとめて削除。直感的で気持ちいい操作感です。

▸ 連続削除（加速あり）
⌫ を長押しすると連続削除が始まり、押し続けるほどどんどん加速します。長い文章もすぐに消せます。

▸ カーソル移動
スペースキーを左右にスライドするだけでカーソルを自由に移動できます。文章の途中を修正するのが格段にラクになります。

▸ 取り消し（Undo）
⤺ キーで直前の入力や削除を取り消せます。

▸ 10種類のテーマ
System / Paper / Sakura / Terminal / Neon / Midnight / Sunset / Wood / Metal / Ice
キーボード内の ◑ ボタンから切り替えられます。

【対応キーボード】
・Wipe Japanese：日本語フリック入力（ひらがな・漢字変換）＋ 英語 QWERTY
・Wipe English：英語 QWERTY のみ

【設定方法】
① 設定 → 一般 → キーボード → キーボードを追加
② Wipe Japanese または Wipe English を選択
③ フルアクセスを許可

---

## 説明文（English）

Hold ⌫ and slide left. Highlight the range you want gone, then let go.

Wipe is a keyboard built around one idea: deleting text should feel as smooth as writing it.

FEATURES

▸ Range Delete
Press and hold ⌫, then swipe left to select a range of text. A red highlight shows exactly what will be deleted in real time. Release to erase it all at once.

▸ Continuous Delete with Acceleration
Hold ⌫ to delete continuously. The longer you hold, the faster it goes.

▸ Cursor Control
Slide the space bar left or right to move the cursor precisely — no more tapping between characters.

▸ Undo
Tap ⤺ to undo your last input or deletion.

▸ 10 Themes
System · Paper · Sakura · Terminal · Neon · Midnight · Sunset · Wood · Metal · Ice
Switch themes from inside the keyboard with the ◑ button.

TWO KEYBOARDS INCLUDED
• Wipe Japanese — flick input for kana/kanji + English QWERTY
• Wipe English — English QWERTY only

SETUP
1. Settings → General → Keyboard → Add New Keyboard
2. Select Wipe Japanese or Wipe English
3. Tap Allow Full Access

---

## App Store Connect 設定メモ

- カテゴリ: Utilities（ユーティリティ）
- 年齢制限: 4+
- 価格: 無料
- App 内課金: なし（初回リリース）

## 必要な新規 GitHub Secrets（App Store ビルド用）

| Secret 名 | 取得場所 | 内容 |
|-----------|---------|------|
| `APPSTORE_PROVISIONING_PROFILE` | Developer Portal → Profiles | メインアプリ App Store プロファイル（base64） |
| `APPSTORE_PROVISIONING_PROFILE_KEYBOARD` | Developer Portal → Profiles | Wipe Japanese App Store プロファイル（base64） |
| `APPSTORE_PROVISIONING_PROFILE_KEYBOARD_EN` | Developer Portal → Profiles | Wipe English App Store プロファイル（base64、任意） |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect → Users → Keys | Key ID（例: ABCD123456） |
| `APP_STORE_CONNECT_API_KEY_ISSUER_ID` | 同上 | Issuer ID（UUID形式） |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | 同上（.p8ファイル） | base64エンコードした .p8 の中身 |

※ API Key Secrets が未設定の場合は IPA が Actions Artifact として保存されるので、
  Transporter アプリ（Mac）で手動アップロード可能。

## App Store Connect プロビジョニングプロファイル 作成時の名前

Developer Portal で作成する際、以下の名前を使うこと（build-appstore.yml と一致させる）:
- メインアプリ: `Wipe App Store`
- Wipe Japanese: `Wipe Keyboard App Store`
- Wipe English: `Wipe English Keyboard App Store`
