import SwiftBedrockService
import Hummingbird
import Foundation

extension TextCompletion: ResponseCodable {}

struct TextCompletionInput: Codable {
    let prompt: String
    let maxTokens: Int?
    let temperature: Double?
}
