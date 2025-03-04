import Foundation

public struct AnthropicRequestBody: Codable {
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

struct AnthropicResponseBody: ContainsTextCompletion {
    let id: String
    let type: String
    let role: String
    let model: String
    let content: [Content]
    let stop_reason: String
    let stop_sequence: String?
    let usage: Usage

    private init(from data: Data) throws {
        let decoder = JSONDecoder()
        self = try decoder.decode(AnthropicResponseBody.self, from: data)
    }

    public func getTextCompletion() throws -> TextCompletion {
        guard let completion = self.content[0].text else {
            throw SwiftBedrockError.completionNotFound("AnthropicResponseBody: content[0].text is nil")
        }
        return TextCompletion(completion)
    }

    struct Content: Codable {
        let type: String
        let text: String?
        let thinking: String?
    }

    struct Usage: Codable {
        let input_tokens: Int
        let output_tokens: Int
    }
}
