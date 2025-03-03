@preconcurrency import AWSBedrock
@preconcurrency import AWSBedrockRuntime
import AWSClientRuntime
import AWSSDKIdentity
import Foundation

public struct SwiftBedrock: Sendable {
    var region = "us-east-1"

    public init() {}

    // private func initializeLogging() async {
    //     await SDKLoggingSystem().initialize(logLevel: .warning)
    // }

    private func configureBedrockRuntimeClient() async throws -> BedrockRuntimeClient {
        let identityResolver = try SSOAWSCredentialIdentityResolver()

        let runtimeClientConfig =
            try await BedrockRuntimeClient.BedrockRuntimeClientConfiguration(
                region: "us-east-1")
        runtimeClientConfig.awsCredentialIdentityResolver = identityResolver

        return BedrockRuntimeClient(config: runtimeClientConfig)
    }

    private func configureBedrockClient(region: String = "us-east-1") async throws -> BedrockClient
    {
        let identityResolver = try SSOAWSCredentialIdentityResolver()
        let clientConfig = try await BedrockClient.BedrockClientConfiguration(
            region: region)
        clientConfig.awsCredentialIdentityResolver = identityResolver

        return BedrockClient(config: clientConfig)
    }

    public func listModels() async throws -> [ModelInfo] {
        let client = try await configureBedrockClient()
        let response = try await client.listFoundationModels(input: ListFoundationModelsInput())
        var modelsInfo: [ModelInfo] = []
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

    private func AnthropicTextCompletion(
        model: BedrockModel, prompt: String, maxTokens: Int, temperature: Double
    )
        async throws -> TextCompletion
    {
        let modelId = model.rawValue
        let runtimeClient = try await configureBedrockRuntimeClient()

        let anthropicRequest = AnthropicRequest(modelId: modelId, prompt: prompt)
        let input: InvokeModelInput = anthropicRequest.getInvokeModelInput()
        let response = try await runtimeClient.invokeModel(
            input: input)
        let anthropicResponse = try AnthropicResponse(from: response.body!)  // FIXME
        return anthropicResponse.getTextCompletion()
    }

    private func TitanTextCompletion(
        model: BedrockModel, prompt: String, maxTokens: Int, temperature: Double
    )
        async throws -> TextCompletion
    {
        let modelId = model.rawValue
        let runtimeClient = try await configureBedrockRuntimeClient()

        let titanRequest = TitanRequest(modelId: modelId, prompt: prompt)
        let input: InvokeModelInput = titanRequest.getInvokeModelInput()
        let response = try await runtimeClient.invokeModel(
            input: input)
        let titanResponse = try TitanResponse(from: response.body!)  // FIXME
        return titanResponse.getTextCompletion()
    }

    private func NovaTextCompletion(
        model: BedrockModel, prompt: String, maxTokens: Int, temperature: Double
    )
        async throws -> TextCompletion
    {
        let modelId = model.rawValue
        let runtimeClient = try await configureBedrockRuntimeClient()

        let novaRequest = NovaRequest(modelId: modelId, prompt: prompt)
        let input: InvokeModelInput = novaRequest.getInvokeModelInput()
        let response = try await runtimeClient.invokeModel(
            input: input)
        let novaResponse = try NovaResponse(from: response.body!)  // FIXME
        return novaResponse.getTextCompletion()
    }

    public func completeText(
        _ text: String, with model: BedrockModel, maxTokens: Int? = 300, temperature: Double? = 0.6
    ) async throws -> TextCompletion {
        let maxTokens = maxTokens ?? 300
        let temperature = temperature ?? 0.6

        if model.isAnthropic() {
            return try await AnthropicTextCompletion(
                model: model, prompt: text, maxTokens: maxTokens, temperature: temperature)
        } else if model.isTitan() {
            return try await TitanTextCompletion(
                model: model, prompt: text, maxTokens: maxTokens, temperature: temperature)
        } else if model.isNova() {
            print("NOVA")
            return try await NovaTextCompletion(
                model: model, prompt: text, maxTokens: maxTokens, temperature: temperature)
        } else {
            // FIXME: throw BedrockError.unknownModel
            return TextCompletion("Model not implemented")
        }
    }
}
