import Foundation
import KanaKanjiConverterModuleWithDefaultDictionary

final class KanjiConverter {
    static let shared = KanjiConverter()

    private let converter = KanaKanjiConverter()
    private let documentsURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
    }()

    private init() {}

    func candidates(for hiragana: String, n: Int = 12) -> [String] {
        guard !hiragana.isEmpty else { return [] }
        var composing = ComposingText()
        composing.insertAtCursorPosition(hiragana, inputStyle: .direct)

        let options = ConvertRequestOptions.withDefaultDictionary(
            N_best: n,
            requireJapanesePrediction: true,
            requireEnglishPrediction: false,
            keyboardLanguage: .ja_JP,
            learningType: .inputAndOutput,
            memoryDirectoryURL: documentsURL,
            sharedContainerURL: documentsURL,
            metadata: nil
        )
        let result = converter.requestCandidates(composing, options: options)
        var list = result.mainResults.map { $0.text }
        if !list.contains(hiragana) { list.append(hiragana) }
        return list
    }
}
