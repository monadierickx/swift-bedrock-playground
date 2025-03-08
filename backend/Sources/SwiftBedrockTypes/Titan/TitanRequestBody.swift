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
