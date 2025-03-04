@preconcurrency import AWSBedrock
@preconcurrency import AWSBedrockRuntime
import AWSClientRuntime
import AWSSDKIdentity
import Foundation

public struct SwiftBedrock: Sendable {
    var region: String

    public init(region: String = "us-east-1") {
        self.region = region
    }

    // FIXME later: getBedrockConfig -> T and getBedrockClient() -> T
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

    /// Lists all available foundation models from Amazon Bedrock
    /// - Throws: SwiftBedrockError.invalidResponse
    /// - Returns: An array of ModelInfo objects containing details about each available model.
    public func listModels() async throws -> [ModelInfo] {
        let client = try await configureBedrockClient()
        let response = try await client.listFoundationModels(input: ListFoundationModelsInput())
        guard let models = response.modelSummaries else {
            throw SwiftBedrockError.invalidResponse(
                "Something went wrong while extracting the modelSummaries from the response.")
        }
        var modelsInfo: [ModelInfo] = []
        modelsInfo = models.compactMap { (model) -> ModelInfo? in
            guard let modelId = model.modelId,
                let providerName = model.providerName,
                let modelName = model.modelName
            else {
                return nil
            }
            return ModelInfo(
                modelName: modelName,
                providerName: providerName,
                modelId: modelId)
        }
        return modelsInfo
    }

    /// Generates a text completion using a specified model.
    /// - Parameters:
    ///   - text: the text to be completed
    ///   - model: the BedrockModel that will be used to generate the completion
    ///   - maxTokens: the maximum amount of tokens in the completion (must be at least 1) optional, default 300
    ///   - temperature: the temperature used to generate the completion (must be a value between 0 and 1) optional, default 0.6
    /// - Throws: SwiftBedrockError.invalidMaxTokens if maxTokens is less than 1
    ///           SwiftBedrockError.invalidTemperature if temperature is not between 0 and 1
    ///           SwiftBedrockError.invalidResponse if the response body is missing
    /// - Returns: a TextCompletion object containing the generated text from the model
    public func completeText(
        _ text: String, with model: BedrockModel, maxTokens: Int? = nil, temperature: Double? = nil
    ) async throws -> TextCompletion {
        let maxTokens = maxTokens ?? 300
        guard maxTokens >= 1 else {
            throw SwiftBedrockError.invalidMaxTokens(
                "MaxTokens should be at least 1. MaxTokens: \(maxTokens)")
        }

        let temperature = temperature ?? 0.6
        guard temperature >= 0 && temperature <= 1 else {
            throw SwiftBedrockError.invalidTemperature(
                "Temperature should be a value between 0 and 1. Temperature: \(temperature)")
        }

        let request: BedrockRequestBody = try BedrockRequestBody(
            model: model, prompt: text, maxTokens: maxTokens, temperature: temperature)
        let runtimeClient = try await configureBedrockRuntimeClient()
        let input: InvokeModelInput = try request.getInvokeModelInput()
        let response = try await runtimeClient.invokeModel(input: input)
        guard let responseBody = response.body else {
            throw SwiftBedrockError.invalidResponse(
                "Something went wrong while extracting body from response.")
        }
        let bedrockResponseBody: BedrockResponseBody = try BedrockResponseBody(
            body: responseBody, model: model)
        return try bedrockResponseBody.getTextCompletion()
    }
}
