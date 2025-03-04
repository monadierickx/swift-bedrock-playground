

// public struct AnthropicRequest: BedrockRequest {
//     // let modelId: String
//     // let contentType: String
//     // let accept: String
//     let body: AnthropicBody

//     public init(modelId: String, prompt: String, maxTokens: Int? = 300, temperature: Double? = 0.6)
//     {
//         self.modelId = modelId
//         self.contentType = "application/json"
//         self.accept = "application/json"
//         self.body = AnthropicBody(
//             maxTokens: maxTokens ?? 300,
//             temperature: temperature ?? 0.6,
//             messages: [
//                 AnthropicMessage(role: .user, content: [AnthropicContent(text: prompt)])
//             ])
//     }

// public func getInvokeModelInput(body: Codable) -> InvokeModelInput {
//     do {
//         let jsonData: Data = try JSONEncoder().encode(body)
//         return InvokeModelInput(
//             accept: accept,
//             body: jsonData,
//             contentType: contentType,
//             modelId: modelId)
//     } catch {
//         print("Encoding error: \(error)")
//         fatalError()  // FIXME
//     }
// }

// public func getBody() -> Codable {
//     return self.body
// }

public struct AnthropicBody: Codable {
    let anthropic_version: String
    let max_tokens: Int
    let temperature: Double
    let messages: [AnthropicMessage]

    // FIXME: nice init 

    init(maxTokens: Int, temperature: Double, messages: [AnthropicMessage]) {
        self.anthropic_version = "bedrock-2023-05-31"
        self.max_tokens = maxTokens
        self.temperature = temperature
        self.messages = messages
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

// }

struct AnthropicResponse: BedrockResponse {
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
        return TextCompletion(self.content[0].text!)  // FIXME
    }
}
