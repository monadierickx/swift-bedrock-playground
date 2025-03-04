import Foundation

public struct NovaRequestBody: Codable {
    let inferenceConfig: InferenceConfig
    let messages: [Message]

    public init(prompt: String, maxTokens: Int, temperature: Double) {
        self.inferenceConfig = InferenceConfig(max_new_tokens: maxTokens)
        self.messages = [Message(role: .user, content: [Content(text: prompt)])]
    }

    public struct InferenceConfig: Codable {
        let max_new_tokens: Int
    }

    public struct Message: Codable {
        let role: Role
        let content: [Content]
    }

    public struct Content: Codable {
        let text: String
    }
}

struct NovaResponseBody: ContainsTextCompletion {
    let output: Output
    let stopReason: String
    let usage: Usage

    private init(from data: Data) throws {
        let decoder = JSONDecoder()
        self = try decoder.decode(NovaResponseBody.self, from: data)
    }

    public func getTextCompletion() -> TextCompletion {
        return TextCompletion(output.message.content[0].text)
    }

    struct Output: Codable {
        let message: Message
    }

    struct Message: Codable {
        let content: [Content]
        let role: Role
    }

    struct Content: Codable {  // FIXME: DRY
        let text: String
    }

    struct Usage: Codable {
        let inputTokens: Int
        let outputTokens: Int
        let totalTokens: Int
        let cacheReadInputTokenCount: Int
        let cacheWriteInputTokenCount: Int
    }
}
