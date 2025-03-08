import Hummingbird
import Foundation

import SwiftBedrockService
import SwiftBedrockTypes

extension TextCompletion: ResponseCodable {}

struct TextCompletionInput: Codable {
    let prompt: String
    let maxTokens: Int?
    let temperature: Double?
}
