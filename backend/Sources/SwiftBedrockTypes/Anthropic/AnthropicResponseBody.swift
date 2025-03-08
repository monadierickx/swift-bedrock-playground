import Foundation

public struct AnthropicResponseBody: ContainsTextCompletion {
    let id: String
    let type: String
    let role: String
    let model: String
    let content: [Content]
    let stop_reason: String
    let stop_sequence: String?
    let usage: Usage

//    private init(from data: Data) throws {
//        let decoder = JSONDecoder()
//        self = try decoder.decode(AnthropicResponseBody.self, from: data)
//    }

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
