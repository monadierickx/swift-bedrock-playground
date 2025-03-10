@preconcurrency import AWSBedrockRuntime
import Foundation
import SwiftBedrockTypes

struct BedrockRequest {
    let model: BedrockModel
    let contentType: String
    let accept: String
    private let body: BedrockBodyCodable

    private init(
        model: BedrockModel, body: BedrockBodyCodable, contentType: String = "application/json",
        accept: String = "application/json"
    ) {
        self.model = model
        self.body = body
        self.contentType = contentType
        self.accept = accept
    }

    // MARKIT: text
    static func createTextRequest(
        model: BedrockModel, prompt: String, maxTokens: Int = 300, temperature: Double = 0.6
    ) throws -> BedrockRequest {
        try .init(model: model, prompt: prompt, maxTokens: maxTokens, temperature: temperature)
    }

    private init(
        model: BedrockModel, prompt: String, maxTokens: Int, temperature: Double
    ) throws {
        guard model.outputModality.contains(.text) else {
            throw SwiftBedrockError.invalidModel("Modality of \(model.rawValue) is not text")
        }
        var body: BedrockBodyCodable
        switch model.family {
        case .anthropic:
            body = AnthropicRequestBody(
                prompt: prompt, maxTokens: maxTokens, temperature: temperature)
        case .titan:
            body = TitanRequestBody(
                prompt: prompt, maxTokens: maxTokens, temperature: temperature)
        case .nova:
            body = NovaRequestBody(
                prompt: prompt, maxTokens: maxTokens, temperature: temperature)
        default:
            throw SwiftBedrockError.invalidModel(model.rawValue)
        }
        self.init(model: model, body: body)
    }

    // MARKIT: image
    public static func createImageRequest(model: BedrockModel, prompt: String, nrOfImages: Int) throws -> BedrockRequest {
        try .init(model: model, prompt: prompt, nrOfImages: nrOfImages)
    }

    private init(model: BedrockModel, prompt: String, nrOfImages: Int) throws {
        guard model.outputModality.contains(.image) else {
            throw SwiftBedrockError.invalidModel("Modality of \(model.rawValue) is not image")
        }
        var body: BedrockBodyCodable
        switch model.family {
        case .titan, .nova:
            body = AmazonImageRequestBody(prompt: prompt, nrOfImages: nrOfImages)
        default:
            throw SwiftBedrockError.invalidModel(model.rawValue)
        }
        self.init(model: model, body: body)
    }

    public func getInvokeModelInput() throws -> InvokeModelInput {
        do {
            let jsonData: Data = try JSONEncoder().encode(self.body)
            return InvokeModelInput(
                accept: self.accept,
                body: jsonData,
                contentType: self.contentType,
                modelId: model.rawValue)
        } catch {
            throw SwiftBedrockError.encodingError(
                "Something went wrong while encoding the request body to JSON for InvokeModelInput: \(error)"
            )
        }
    }

}
