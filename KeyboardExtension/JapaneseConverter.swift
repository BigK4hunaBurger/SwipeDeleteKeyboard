import Foundation

class JapaneseConverter {
    private(set) var pending = ""

    // Returns committed kana string (empty if still buffering)
    func input(_ char: String) -> String {
        pending += char.lowercased()

        if let kana = table[pending] {
            pending = ""
            return kana
        }

        if table.keys.contains(where: { $0.hasPrefix(pending) }) {
            return ""
        }

        // No continuation possible — try to salvage prefix
        var committed = ""
        while !pending.isEmpty {
            var matched = false
            for len in stride(from: pending.count, through: 1, by: -1) {
                let prefix = String(pending.prefix(len))
                if let kana = table[prefix] {
                    committed += kana
                    pending = String(pending.dropFirst(len))
                    matched = true
                    break
                }
            }
            if !matched {
                committed += String(pending.prefix(1))
                pending = String(pending.dropFirst())
            }
        }
        return committed
    }

    func deleteFromBuffer() -> Bool {
        guard !pending.isEmpty else { return false }
        pending = String(pending.dropLast())
        return true
    }

    func flush() -> String {
        let result = pending
        pending = ""
        return result
    }

    // swiftlint:disable line_length
    private let table: [String: String] = [
        "a":"あ","i":"い","u":"う","e":"え","o":"お",
        "ka":"か","ki":"き","ku":"く","ke":"け","ko":"こ",
        "sa":"さ","si":"し","su":"す","se":"せ","so":"そ","shi":"し",
        "ta":"た","ti":"ち","tu":"つ","te":"て","to":"と","chi":"ち","tsu":"つ",
        "na":"な","ni":"に","nu":"ぬ","ne":"ね","no":"の",
        "ha":"は","hi":"ひ","hu":"ふ","he":"へ","ho":"ほ","fu":"ふ",
        "ma":"ま","mi":"み","mu":"む","me":"め","mo":"も",
        "ya":"や","yu":"ゆ","yo":"よ",
        "ra":"ら","ri":"り","ru":"る","re":"れ","ro":"ろ",
        "wa":"わ","wo":"を","nn":"ん",
        "ga":"が","gi":"ぎ","gu":"ぐ","ge":"げ","go":"ご",
        "za":"ざ","zi":"じ","zu":"ず","ze":"ぜ","zo":"ぞ","ji":"じ",
        "da":"だ","di":"ぢ","du":"づ","de":"で","do":"ど",
        "ba":"ば","bi":"び","bu":"ぶ","be":"べ","bo":"ぼ",
        "pa":"ぱ","pi":"ぴ","pu":"ぷ","pe":"ぺ","po":"ぽ",
        "kya":"きゃ","kyu":"きゅ","kyo":"きょ",
        "sha":"しゃ","shu":"しゅ","sho":"しょ",
        "cha":"ちゃ","chu":"ちゅ","cho":"ちょ",
        "nya":"にゃ","nyu":"にゅ","nyo":"にょ",
        "hya":"ひゃ","hyu":"ひゅ","hyo":"ひょ",
        "mya":"みゃ","myu":"みゅ","myo":"みょ",
        "rya":"りゃ","ryu":"りゅ","ryo":"りょ",
        "gya":"ぎゃ","gyu":"ぎゅ","gyo":"ぎょ",
        "ja":"じゃ","ju":"じゅ","jo":"じょ",
        "bya":"びゃ","byu":"びゅ","byo":"びょ",
        "pya":"ぴゃ","pyu":"ぴゅ","pyo":"ぴょ",
        "xtu":"っ","ltu":"っ","xtsu":"っ",
        "xa":"ぁ","xi":"ぃ","xu":"ぅ","xe":"ぇ","xo":"ぉ",
        "xya":"ゃ","xyu":"ゅ","xyo":"ょ",
        "vu":"ヴ",
    ]
}
