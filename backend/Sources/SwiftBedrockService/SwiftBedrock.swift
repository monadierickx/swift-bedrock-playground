@preconcurrency import AWSBedrock
@preconcurrency import AWSBedrockRuntime
import AWSClientRuntime
import AWSSDKIdentity
import Foundation

public struct SwiftBedrock: Sendable {
    var region = "us-east-1"  // FIXME

    public init() {}

    // TODO getBedrockConfig -> T and getBedrockClient() -> T
    private func configureBedrockRuntimeClient() async throws -> BedrockRuntimeClient {
        let identityResolver = try SSOAWSCredentialIdentityResolver()  // FIXME later
        let runtimeClientConfig =
            try await BedrockRuntimeClient.BedrockRuntimeClientConfiguration(
                region: region)
        runtimeClientConfig.awsCredentialIdentityResolver = identityResolver

        return BedrockRuntimeClient(config: runtimeClientConfig)
    }

    private func configureBedrockClient() async throws -> BedrockClient {
        let identityResolver = try SSOAWSCredentialIdentityResolver()
        let clientConfig = try await BedrockClient.BedrockClientConfiguration(
            region: region)
        clientConfig.awsCredentialIdentityResolver = identityResolver

        return BedrockClient(config: clientConfig)
    }

    /// Lists all models
    /// - Throws: TODO
    /// - Returns: an array of ModelInfo
    public func listModels() async throws -> [ModelInfo] {
        let client = try await configureBedrockClient()  // create
        let response = try await client.listFoundationModels(input: ListFoundationModelsInput())
        var modelsInfo: [ModelInfo] = []

        // Map: first check for nil (guard), use map instead of for
        if let models = response.modelSummaries {
            for model in models {
                let info: ModelInfo = ModelInfo(
                    modelName: model.modelName ?? "N/A",
                    providerName: model.providerName ?? "N/A",
                    modelId: model.modelId ?? "N/A")
                modelsInfo.append(info)
            }
        }
        return modelsInfo
    }

    private func textCompletion<Response: BedrockResponse>(
        request: BedrockRequest
    )
        async throws -> Response
    {
        let runtimeClient = try await configureBedrockRuntimeClient()

        let input: InvokeModelInput = request.getInvokeModelInput()
        let response = try await runtimeClient.invokeModel(
            input: input)
        return try .init(from: response.body!)  // FIXME: guard
    }

    // private func AnthropicTextCompletion(
    //     model: BedrockModel, prompt: String, maxTokens: Int, temperature: Double
    // )
    //     async throws -> TextCompletion
    // {
    //     let modelId = model.rawValue
    //     let runtimeClient = try await configureBedrockRuntimeClient()

    //     let anthropicRequest = AnthropicRequest(
    //         modelId: modelId, prompt: prompt, maxTokens: maxTokens, temperature: temperature)

    //     let input: InvokeModelInput = anthropicRequest.getInvokeModelInput(
    //         body: anthropicRequest.getBody())
    //     let response = try await runtimeClient.invokeModel(
    //         input: input)
    //     let anthropicResponse = try AnthropicResponse(from: response.body!)  // FIXME
    //     return anthropicResponse.getTextCompletion()
    // }

    // private func TitanTextCompletion(
    //     model: BedrockModel, prompt: String, maxTokens: Int, temperature: Double
    // )
    //     async throws -> TextCompletion
    // {
    //     let modelId = model.rawValue
    //     let runtimeClient = try await configureBedrockRuntimeClient()

    //     let titanRequest = TitanRequest(
    //         modelId: modelId, prompt: prompt, maxTokens: maxTokens, temperature: temperature)
    //     let input: InvokeModelInput = titanRequest.getInvokeModelInput()
    //     let response = try await runtimeClient.invokeModel(
    //         input: input)
    //     let titanResponse = try TitanResponse(from: response.body!)  // FIXME
    //     return titanResponse.getTextCompletion()
    // }

    // private func NovaTextCompletion(
    //     model: BedrockModel, prompt: String, maxTokens: Int, temperature: Double
    // )
    //     async throws -> TextCompletion
    // {
    //     let modelId = model.rawValue
    //     let runtimeClient = try await configureBedrockRuntimeClient()

    //     let novaRequest = NovaRequest(
    //         modelId: modelId, prompt: prompt, maxTokens: maxTokens, temperature: temperature)
    //     let input: InvokeModelInput = novaRequest.getInvokeModelInput()
    //     let response = try await runtimeClient.invokeModel(
    //         input: input)
    //     let novaResponse = try NovaResponse(from: response.body!)  // FIXME
    //     return novaResponse.getTextCompletion()
    // }

    /// Generates a text completion using a specified model.
    /// - Parameters:
    ///   - text: the text to be completed
    ///   - model: the BedrockModel that will be used to generate the completion
    ///   - maxTokens: the maximum amount of tokens in the completion (must be at least 1) optional, default 300
    ///   - temperature: the temperature used to generate the completion (must be a value between 0 and 1) optional, default 0.6
    /// - Throws: // TODO
    /// - Returns: a TextCompletion with the generated text
    public func completeText(
        _ text: String, with model: BedrockModel, maxTokens: Int? = nil, temperature: Double? = nil
    ) async throws -> TextCompletion {
        let maxTokens = maxTokens ?? 300
        // guard maxTokens < 1 else {
        // maxTokens = 1
        // TODO error!
        // }

        let temperature = temperature ?? 0.6
        // guard temperature < 1.0 // FIXME

        // FIXME: switch

        // switch model {
        // case .isAnthropic():
        //     let anthropicRequest = AnthropicRequest(
        //         modelId: model.rawValue, prompt: text, maxTokens: maxTokens,
        //         temperature: temperature)
        //     let response: AnthropicResponse = try await textCompletion(request: anthropicRequest)
        //     return response.getTextCompletion()
        // default:
        //     return TextCompletion("Model not implemented")
        // }

        if model.isAnthropic() {
            let body: AnthropicBody = AnthropicBody(maxTokens: maxTokens, temperature: temperature, messages: [])
            let request: BedrockRequest = BedrockRequest(modelId: model.rawValue, body: body)
            let response: AnthropicResponse = try await textCompletion(request: request)
            return response.getTextCompletion()
        // } else if model.isTitan() {
        //     let titanRequest = TitanRequest(
        //         modelId: model.rawValue, prompt: text, maxTokens: maxTokens,
        //         temperature: temperature)
        //     let response: TitanResponse = try await textCompletion(request: titanRequest)
        //     return response.getTextCompletion()
        // } else if model.isNova() {
        //     let novaRequest = NovaRequest(
        //         modelId: model.rawValue, prompt: text, maxTokens: maxTokens,
        //         temperature: temperature)
        //     let response: NovaResponse = try await textCompletion(request: novaRequest)
        //     return response.getTextCompletion()
        } else {
            // FIXME: throw BedrockError.unknownModel
            return TextCompletion("Model not implemented")
        }
    }
}
