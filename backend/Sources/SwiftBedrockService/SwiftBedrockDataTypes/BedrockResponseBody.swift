@preconcurrency import AWSBedrockRuntime
import Foundation

public struct BedrockResponseBody {
    let model: BedrockModel
    let contentType: String
    let body: ContainsTextCompletion

    private init(model: BedrockModel, contentType: String, body: ContainsTextCompletion) {
        self.model = model
        self.contentType = contentType
        self.body = body
    }

    public init(body: Data, model: BedrockModel, contentType: String = "application/json") throws {
        self.contentType = contentType
        self.model = model

        do {
            let decoder = JSONDecoder()
            switch model.family {
            case .anthropic:
                self.body = try decoder.decode(AnthropicResponseBody.self, from: body)
            case .titan:
                self.body = try decoder.decode(TitanResponseBody.self, from: body)
            case .nova:
                self.body = try decoder.decode(NovaResponseBody.self, from: body)
            default:
                throw SwiftBedrockError.invalidModel(model.rawValue)
            }
        } catch {
            throw SwiftBedrockError.invalidResponse(body)
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

// suggestion:
public protocol ContainsTextCompletion: Codable {
    func getTextCompletion() throws -> TextCompletion
}
