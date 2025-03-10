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

struct ImageGenerationInput: Codable {
    let prompt: String
    let stylePreset: String?
    let referenceImagePath: String?

    init(prompt: String, stylePreset: String? = "") {
        self.prompt = prompt
        self.stylePreset = stylePreset
        self.referenceImagePath = nil
    }

    init(prompt: String, referenceImagePath: String) {
        self.prompt = prompt
        self.stylePreset = ""
        self.referenceImagePath = referenceImagePath
    }
}

extension ImageGenerationOutput: ResponseCodable {}
