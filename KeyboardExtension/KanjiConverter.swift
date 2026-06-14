import Foundation
import KanaKanjiConverterModuleWithDefaultDictionary

@MainActor
final class KanjiConverter {
    static let shared = KanjiConverter()

    private let converter = KanaKanjiConverter()
    private let documentsURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
    }()

    private init() {}

    func candidates(for hiragana: String, n: Int = 12) -> [(text: String, rubyCount: Int)] {
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
        var list = result.mainResults.map { (text: $0.text, rubyCount: $0.rubyCount) }
        if !list.contains(where: { $0.text == hiragana }) {
            list.append((text: hiragana, rubyCount: hiragana.count))
        }
        return list
    }
}
