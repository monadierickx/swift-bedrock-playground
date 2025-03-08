@preconcurrency import AWSBedrockRuntime
import Foundation

import SwiftBedrockTypes

public struct BedrockResponse {
    let model: BedrockModel
    let contentType: String
    let body: ContainsTextCompletion

    private init(model: BedrockModel, contentType: String = "application/json", body: ContainsTextCompletion) {
        self.model = model
        self.contentType = contentType
        self.body = body
    }

    public init(body data: Data, model: BedrockModel) throws {
        do {
            var body: ContainsTextCompletion
            let decoder = JSONDecoder()
            switch model.family {
            case .anthropic:
                body = try decoder.decode(AnthropicResponseBody.self, from: data)
            case .titan:
                body = try decoder.decode(TitanResponseBody.self, from: data)
            case .nova:
                body = try decoder.decode(NovaResponseBody.self, from: data)
            default:
                throw SwiftBedrockError.invalidModel(model.rawValue)
            }
            self.init(model: model, body: body)
        } catch {
            throw SwiftBedrockError.invalidResponseBody(data)
        }
    }

    public func getTextCompletion() throws -> TextCompletion {
        do {
            return try body.getTextCompletion()
        } catch {
            throw SwiftBedrockError.decodingError(
                "Something went wrong while decoding the request body to find the completion: \(error)"
            )
        }
    }
}
