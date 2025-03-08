@preconcurrency import AWSBedrock
@preconcurrency import AWSBedrockRuntime
import AWSClientRuntime
import AWSSDKIdentity
import Foundation
import Logging

import SwiftBedrockTypes

public struct SwiftBedrock {
    let region: String
    private let bedrockClient: MyBedrockClientProtocol
    private let bedrockRuntimeClient: MyBedrockRuntimeClientProtocol
    var logger: Logger

    public init(
        region: String = "us-east-1",
        bedrockClient: MyBedrockClientProtocol? = nil,
        bedrockRuntimeClient: MyBedrockRuntimeClientProtocol? = nil
    ) async throws {
        if bedrockClient == nil || bedrockRuntimeClient == nil {
            self = try await SwiftBedrock(region: region)
        } else {
            self.logger = Logger(label: "swiftbedrock.service")  // CHECKME: different name?
            self.logger.trace("Initializing SwiftBedrock", metadata: ["region": .string(region)])
            self.region = region
            self.bedrockClient = bedrockClient!
            self.bedrockRuntimeClient = bedrockRuntimeClient!
        }
        self.logger.trace("Initialized SwiftBedrock", metadata: ["region": .string(region)])
    }

    private init(region: String) async throws {
        self.logger = Logger(label: "swiftbedrock.service")
        self.logger.trace("Initializing SwiftBedrock", metadata: ["region": .string(region)])
        self.region = region

        let identityResolver = try SSOAWSCredentialIdentityResolver()  // FIXME later: allow other methods
        let clientConfig =
            try await BedrockClient.BedrockClientConfiguration(
                region: region)
        clientConfig.awsCredentialIdentityResolver = identityResolver
        let runtimeClientConfig =
            try await BedrockRuntimeClient.BedrockRuntimeClientConfiguration(
                region: region)
        runtimeClientConfig.awsCredentialIdentityResolver = identityResolver

        self.bedrockClient = BedrockClient(config: clientConfig)
        self.bedrockRuntimeClient = BedrockRuntimeClient(config: runtimeClientConfig)
    }

    /// Lists all available foundation models from Amazon Bedrock
    /// - Throws: SwiftBedrockError.invalidResponse
    /// - Returns: An array of ModelInfo objects containing details about each available model.
    public func listModels() async throws -> [ModelInfo] {
        logger.trace("Fetching foundation models")
        let response = try await bedrockClient.listFoundationModels(
            input: ListFoundationModelsInput())
        guard let models = response.modelSummaries else {
            logger.info("Failed to extract modelSummaries from response")
            throw SwiftBedrockError.invalidResponse(
                "Something went wrong while extracting the modelSummaries from the response.")
        }
        var modelsInfo: [ModelInfo] = []
        modelsInfo = models.compactMap { (model) -> ModelInfo? in
            guard let modelId = model.modelId,
                let providerName = model.providerName,
                let modelName = model.modelName
            else {
                logger.debug("Skipping model due to missing required properties")
                return nil
            }
            return ModelInfo(
                modelName: modelName,
                providerName: providerName,
                modelId: modelId)
        }
        logger.trace(
            "Fetched foundation models",
            metadata: [
                "models.count": .stringConvertible(modelsInfo.count)
                // "models.content": .stringConvertible(modelsInfo),
            ])
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
        logger.trace(
            "Generating text completion",
            metadata: [
                "model.id": .string(model.rawValue),
                "model.family": .string(model.family.description),
                "prompt": .string(text),
                "maxTokens": .stringConvertible(maxTokens ?? "not defined"),
            ])
        let maxTokens = maxTokens ?? 300
        guard maxTokens >= 1 else {
            logger.debug(
                "Invalid maxTokens", metadata: ["maxTokens": .stringConvertible(maxTokens)])
            throw SwiftBedrockError.invalidMaxTokens(
                "MaxTokens should be at least 1. MaxTokens: \(maxTokens)")
        }

        let temperature = temperature ?? 0.6
        guard temperature >= 0 && temperature <= 1 else {
            logger.debug(
                "Invalid temperature", metadata: ["temperature": .stringConvertible(temperature)])
            throw SwiftBedrockError.invalidTemperature(
                "Temperature should be a value between 0 and 1. Temperature: \(temperature)")
        }

        guard !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            logger.debug("Invalid prompt", metadata: ["prompt": .string(text)])
            throw SwiftBedrockError.invalidPrompt("Prompt is not allowed to be empty.")
        }

        let request: BedrockRequest = try BedrockRequest(
            model: model, prompt: text, maxTokens: maxTokens, temperature: temperature)
        let input: InvokeModelInput = try request.getInvokeModelInput()
        logger.trace(
            "Sending request to invokeModel",
            metadata: [
                "model": .string(model.rawValue), "request": .string(String(describing: input)),
            ])
        let response = try await self.bedrockRuntimeClient.invokeModel(input: input)
        guard let responseBody = response.body else {
            logger.debug(
                "Invalid response",
                metadata: [
                    "response": .string(String(describing: response)),
                    "hasBody": .stringConvertible(response.body != nil),
                ])
            throw SwiftBedrockError.invalidResponse(
                "Something went wrong while extracting body from response.")
        }
        let BedrockResponse: BedrockResponse = try BedrockResponse(
            body: responseBody, model: model)
        logger.trace(
            "Generated text completion",
            metadata: [
                "model": .string(model.rawValue), "response": .string(String(describing: response)),
            ])
        return try BedrockResponse.getTextCompletion()
    }
}
