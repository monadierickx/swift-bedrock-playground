import Foundation

public struct NovaRequestBody: BedrockBodyCodable {
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
