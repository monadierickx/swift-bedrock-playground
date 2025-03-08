import Foundation

public struct AnthropicRequestBody: BedrockBodyCodable {
    let anthropic_version: String
    let max_tokens: Int
    let temperature: Double
    let messages: [AnthropicMessage]

    public init(prompt: String, maxTokens: Int, temperature: Double) {
        self.anthropic_version = "bedrock-2023-05-31"
        self.max_tokens = maxTokens
        self.temperature = temperature
        self.messages = [
            AnthropicMessage(role: .user, content: [AnthropicContent(text: prompt)])
        ]
    }

    public struct AnthropicMessage: Codable {
        let role: Role
        let content: [AnthropicContent]
    }

    public struct AnthropicContent: Codable {
        let type: String
        let text: String

        init(text: String) {
            self.type = "text"
            self.text = text
        }
    }
}
