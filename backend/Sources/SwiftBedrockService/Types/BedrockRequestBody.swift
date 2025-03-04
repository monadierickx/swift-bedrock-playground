@preconcurrency import AWSBedrock
@preconcurrency import AWSBedrockRuntime
import AWSClientRuntime
import AWSSDKIdentity
import Foundation

struct BedrockRequestBody {
    let model: BedrockModel
    let contentType: String
    let accept: String
    let body: Codable

    private init(
        model: BedrockModel, body: Codable, contentType: String = "application/json",
        accept: String = "application/json"
    ) {
        self.model = model
        self.body = body
        self.contentType = contentType
        self.accept = accept
    }

    public init(model: BedrockModel, prompt: String, maxTokens: Int = 300, temperature: Double = 0.6) throws {
        self.model = model
        self.contentType = "application/json"
        self.accept = "application/json"
        switch model.family {
            case .anthropic:
                self.body = AnthropicRequestBody(prompt: prompt, maxTokens: maxTokens, temperature: temperature)
            case .titan:
                self.body = TitanRequestBody(prompt: prompt, maxTokens: maxTokens, temperature: temperature)
            case .nova:
                self.body = NovaRequestBody(prompt: prompt, maxTokens: maxTokens, temperature: temperature)
            default:
                throw BedrockError.invalidModel(model.rawValue)
        }
    }

    func getInvokeModelInput() -> InvokeModelInput {
        do {
            let jsonData: Data = try JSONEncoder().encode(self.body)  // FIXME
            return InvokeModelInput(
                accept: self.accept,
                body: jsonData,
                contentType: self.contentType,
                modelId: model.rawValue)
        } catch {
            print("Encoding error: \(error)")
            fatalError()  // FIXME
        }
    }

}
