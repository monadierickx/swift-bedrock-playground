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

    // private func textCompletion(request: BedrockRequestBody, model: BedrockModel) async throws
    //     -> BedrockResponseBody
    // {
    //     let runtimeClient = try await configureBedrockRuntimeClient()

    //     let input: InvokeModelInput = request.getInvokeModelInput()

    //     let response = try await runtimeClient.invokeModel(input: input)
    //     // return try .init(from: response.body!)
    //     return try BedrockResponseBody(body: response.body!, model: model)  // FIXME: guard
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
        guard maxTokens >= 1 else {
            throw BedrockError.invalidMaxTokens("MaxTokens should be at least 1. MaxTokens: \(maxTokens)")
        }

        let temperature = temperature ?? 0.6
        guard temperature >= 0 && temperature <= 1 else {
            throw BedrockError.invalidTemperature(
                "Temperature should be a value between 0 and 1. Temperature: \(temperature)")
        }

        let request: BedrockRequestBody = try BedrockRequestBody(
            model: model, prompt: text, maxTokens: maxTokens, temperature: temperature)
        let runtimeClient = try await configureBedrockRuntimeClient()
        let input: InvokeModelInput = request.getInvokeModelInput()
        let response = try await runtimeClient.invokeModel(input: input)
        let bedrockResponseBody: BedrockResponseBody = try BedrockResponseBody(
            body: response.body!, model: model)  // FIXME: guard
        return bedrockResponseBody.getTextCompletion()
    }
}
