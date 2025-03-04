@preconcurrency import AWSBedrock
@preconcurrency import AWSBedrockRuntime
import AWSClientRuntime
import AWSSDKIdentity
import Foundation

struct BedrockRequest {
    let modelId: String
    let contentType: String
    let accept: String

    let body: Codable

    private init(
        modelId: String, body: Codable, contentType: String = "application/json",
        accept: String = "application/json"
    ) {
        self.modelId = modelId
        self.body = body
        self.contentType = contentType
        self.accept = accept
    }

    public init(model: BedrockModel, prompt: String, maxTokens: Int = 300, temperature: Double = 0.6){
        switch model {
            case .isAnthropic():
                self.body = AnthropicBody(
                    maxTokens: maxTokens,
                    temperature: temperature,
                    messages: [
                        AnthropicMessage(role: .user, content: [AnthropicContent(text: prompt)])
                    ])
            default:
                fatalError()  // FIXME
        self.modelId = model.rawValue
        }
    }

    func getInvokeModelInput() -> InvokeModelInput {
        do {
            let jsonData: Data = try JSONEncoder().encode(self.body)  // FIXME
            return InvokeModelInput(
                accept: self.accept,
                body: jsonData,
                contentType: self.contentType,
                modelId: modelId)
        } catch {
            print("Encoding error: \(error)")
            fatalError()  // FIXME
        }
    }

}