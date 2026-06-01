import Foundation
import KanaKanjiConverterModuleWithDefaultDictionary

final class KanjiConverter {
    static let shared = KanjiConverter()

    private let converter = KanaKanjiConverter.withDefaultDictionary()
    private let documentsURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
    }()

    private init() {}

    func candidates(for hiragana: String, n: Int = 12) -> [String] {
        guard !hiragana.isEmpty else { return [] }
        var composing = ComposingText()
        composing.insertAtCursorPosition(hiragana, inputStyle: .direct)

        let options = ConvertRequestOptions(
            N_best: n,
            requireJapanesePrediction: .autoMix,
            keyboardLanguage: .ja_JP,
            memoryDirectoryURL: documentsURL,
            sharedContainerURL: documentsURL
        )
        let result = converter.requestCandidates(composing, options: options)
        var list = result.mainResults.map(\.text)
        // Always include original hiragana as fallback
        if !list.contains(hiragana) { list.append(hiragana) }
        return list
    }
}
