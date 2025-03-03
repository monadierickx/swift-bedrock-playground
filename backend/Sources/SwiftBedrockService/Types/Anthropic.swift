@preconcurrency import AWSBedrock
@preconcurrency import AWSBedrockRuntime
import AWSClientRuntime
import AWSSDKIdentity
import Foundation

public struct AnthropicRequest: BedrockRequest {
    let modelId: String
    let contentType: String = "application/json"
    let accept: String = "application/json"
    let body: AnthropicBody

    init(modelId: String, prompt: String, maxTokens: Int? = 300, temperature: Double? = 0.6) {
        self.modelId = modelId
        self.body = AnthropicBody(
            maxTokens: maxTokens ?? 300,
            temperature: temperature ?? 0.6,
            messages: [
                AnthropicMessage(role: .user, content: [AnthropicContent(text: prompt)])
            ])
    }

    func getInvokeModelInput() -> InvokeModelInput {
        // let body = try! JSONEncoder().encode(self.body)
        // return  InvokeModelInput(
        //     // accept: self.accept,
        //     accept: "application/json",
        //     // body: "\(self.body)".data(using: .utf8),
        //     body: """
        //         {
        //             "anthropic_version": "bedrock-2023-05-31",
        //             "messages": \(self.body.messages),
        //             "max_tokens": \(self.body.maxTokens),
        //             "temperature": \(self.body.temperature)
        //         }
        //         """.data(using: .utf8),
        //     // contentType: self.contentType,
        //     contentType: "application/json",
        //     modelId: self.modelId)

        // FIXME
        let messages = """
            [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": "\(self.body.messages[0].content[0].text)"
                        }
                    ]
                }
            ]
            """

        return InvokeModelInput(
            accept: "application/json",
            body: """
                {
                    "anthropic_version": "bedrock-2023-05-31",
                    "messages": \(messages),
                    "max_tokens": \(self.body.maxTokens),
                    "temperature": \(self.body.temperature)
                }
                """.data(using: .utf8),
            contentType: "application/json",
            modelId: modelId)
    }

    public struct AnthropicBody: Codable {
        let anthropicVersion: String = "bedrock-2023-05-31"
        let maxTokens: Int
        let temperature: Double
        let messages: [AnthropicMessage]
    }

    public struct AnthropicMessage: Codable {
        let role: Role
        let content: [AnthropicContent]
    }

    public struct AnthropicContent: Codable {
        let type: String = "text"
        let text: String
    }

}

struct AnthropicResponse: Decodable {
    let id: String
    let type: String
    let role: String
    let model: String
    let content: [Content]
    let stop_reason: String
    let stop_sequence: String?
    let usage: Usage

    struct Content: Decodable {
        let type: String
        let text: String?
        let thinking: String?
    }

    struct Usage: Decodable {
        let input_tokens: Int
        let output_tokens: Int
    }

    public init(from data: Data) throws {
        let decoder = JSONDecoder()
        self = try decoder.decode(AnthropicResponse.self, from: data)
    }

    func getTextCompletion() -> TextCompletion {
        return TextCompletion(self.content[0].text!) // FIXME
    }
}
