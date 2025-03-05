import Foundation

public struct TitanRequestBody: BedrockBodyCodable {
    let inputText: String
    let textGenerationConfig: TextGenerationConfig

    public init(prompt: String, maxTokens: Int, temperature: Double) {
        self.inputText = prompt
        self.textGenerationConfig = TextGenerationConfig(
            maxTokenCount: maxTokens, temperature: temperature)
    }

    public struct TextGenerationConfig: Codable {
        let maxTokenCount: Int
        let temperature: Double
    }
}

struct TitanResponseBody: ContainsTextCompletion {
    let inputTextTokenCount: Int
    let results: [Result]

    private init(from data: Data) throws {
        let decoder = JSONDecoder()
        self = try decoder.decode(TitanResponseBody.self, from: data)
    }

    func getTextCompletion() throws -> TextCompletion {
        return TextCompletion(results[0].outputText)
    }

    struct Result: Codable {
        let tokenCount: Int
        let outputText: String
        let completionReason: String
    }
}
