//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Foundation Models Playground open source project
//
// Copyright (c) 2025 Amazon.com, Inc. or its affiliates
//                    and the Swift Foundation Models Playground project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift Foundation Models Playground project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

@preconcurrency import AWSBedrock
@preconcurrency import AWSBedrockRuntime
import AWSClientRuntime
import AWSSDKIdentity
import Foundation
import Logging
import SwiftBedrockTypes

public struct SwiftBedrock: Sendable {
    let region: Region
    let logger: Logger
    private let bedrockClient: MyBedrockClientProtocol
    private let bedrockRuntimeClient: MyBedrockRuntimeClientProtocol

    public init(
        region: Region = .useast1,
        logger: Logger? = nil,
        bedrockClient: MyBedrockClientProtocol? = nil,
        bedrockRuntimeClient: MyBedrockRuntimeClientProtocol? = nil,
        useSSO: Bool = false
    ) async throws {
        self.logger = logger ?? SwiftBedrock.createLogger("swiftbedrock.service")
        self.logger.trace(
            "Initializing SwiftBedrock", metadata: ["region": .string(region.rawValue)])
        self.region = region

        if bedrockClient != nil && bedrockRuntimeClient != nil {
            self.logger.trace("Using supplied bedrockClient and bedrockRuntimeClient")
            self.bedrockClient = bedrockClient!
            self.bedrockRuntimeClient = bedrockRuntimeClient!
        } else {
            self.logger.trace("Creating bedrockClient and bedrockRuntimeClient")
            self.bedrockClient = try await SwiftBedrock.createBedrockClient(
                region: region, useSSO: useSSO)
            self.logger.trace(
                "Created bedrockRuntimeClient", metadata: ["useSSO": .stringConvertible(useSSO)])
            self.bedrockRuntimeClient = try await SwiftBedrock.createBedrockRuntimeClient(
                region: region, useSSO: useSSO)
            self.logger.trace(
                "Created bedrockRuntimeClient", metadata: ["useSSO": .stringConvertible(useSSO)])

        }
        self.logger.trace(
            "Initialized SwiftBedrock", metadata: ["region": .string(region.rawValue)])
    }

    /// Creates Logger using either the loglevel saved as en environment variable `LOG_LEVEL` or with default `.trace`
    static private func createLogger(_ name: String) -> Logger {
        var logger: Logger = Logger(label: name)
        logger.logLevel =
            ProcessInfo.processInfo.environment["LOG_LEVEL"].flatMap {
                Logger.Level(rawValue: $0.lowercased())
            } ?? .trace  // FIXME: trace for me, later .info
        return logger
    }

    /// Creates a BedrockClient
    static private func createBedrockClient(region: Region, useSSO: Bool = false) async throws
        -> MyBedrockClientProtocol
    {
        var bedrockClient: MyBedrockClientProtocol
        if useSSO {
            let identityResolver = try SSOAWSCredentialIdentityResolver()
            let clientConfig = try await BedrockClient.BedrockClientConfiguration(
                region: region.rawValue)
            clientConfig.awsCredentialIdentityResolver = identityResolver

            bedrockClient = BedrockClient(config: clientConfig)
        } else {
            let defaultResolver = try await BedrockClient.BedrockClientConfiguration(
                region: region.rawValue)
            bedrockClient = BedrockClient(config: defaultResolver)
        }
        return bedrockClient
    }

    /// Creates a BedrockRuntimeClient
    static private func createBedrockRuntimeClient(region: Region, useSSO: Bool = false)
        async throws
        -> MyBedrockRuntimeClientProtocol
    {
        var bedrockRuntimeClient: MyBedrockRuntimeClientProtocol
        if useSSO {
            let identityResolver = try SSOAWSCredentialIdentityResolver()
            let runtimeClientConfig =
                try await BedrockRuntimeClient.BedrockRuntimeClientConfiguration(
                    region: region.rawValue)
            runtimeClientConfig.awsCredentialIdentityResolver = identityResolver

            bedrockRuntimeClient = BedrockRuntimeClient(config: runtimeClientConfig)
        } else {
            let defaultRuntimeResolver =
                try await BedrockRuntimeClient.BedrockRuntimeClientConfiguration(
                    region: region.rawValue)
            bedrockRuntimeClient = BedrockRuntimeClient(config: defaultRuntimeResolver)
        }
        return bedrockRuntimeClient
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
    ///           SwiftBedrockError.invalidPrompt if the prompt is empty
    ///           SwiftBedrockError.invalidResponse if the response body is missing
    /// - Returns: a TextCompletion object containing the generated text from the model
    public func completeText(
        _ text: String, with model: BedrockModel, maxTokens: Int? = nil, temperature: Double? = nil
    ) async throws -> TextCompletion {
        logger.trace(
            "Generating text completion",
            metadata: [
                "model.id": .string(model.id),
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

        let request: BedrockRequest = try BedrockRequest.createTextRequest(
            model: model, prompt: text, maxTokens: maxTokens, temperature: temperature)
        let input: InvokeModelInput = try request.getInvokeModelInput()
        logger.trace(
            "Sending request to invokeModel",
            metadata: [
                "model": .string(model.id), "request": .string(String(describing: input)),
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
                "model": .string(model.id), "response": .string(String(describing: response)),
            ])
        return try BedrockResponse.getTextCompletion()
    }

    /// Generates 1 to 5 image(s) from a text prompt using a specific model.
    /// - Parameters:
    ///   - prompt: the prompt describing the image that should be generated
    ///   - model: the BedrockModel that will be used to generate the image
    ///   - nrOfImages: the number of images that will be generated (must be a number between 1 and 5) optional, default 3
    /// - Throws: SwiftBedrockError.invalidNrOfImages if nrOfImages is not between 1 and 5
    ///           SwiftBedrockError.invalidPrompt if the prompt is empty
    ///           SwiftBedrockError.invalidResponse if the response body is missing
    /// - Returns: a ImageGenerationOutput object containing an array of generated images
    public func generateImage(
        _ prompt: String, with model: BedrockModel, nrOfImages: Int? = nil
    ) async throws -> ImageGenerationOutput {
        logger.trace(
            "Generating image(s)",
            metadata: [
                "model.id": .string(model.id),
                "model.family": .string(model.family.description),
                "prompt": .string(prompt),
                "nrOfImages": .stringConvertible(nrOfImages ?? "not defined"),
            ])

        let nrOfImages = nrOfImages ?? 1  // FIXME: make 3, stays 1 for now for latency
        guard nrOfImages >= 1 && nrOfImages <= 5 else {
            logger.debug(
                "Invalid nrOfImages", metadata: ["nrOfImages": .stringConvertible(nrOfImages)])
            throw SwiftBedrockError.invalidNrOfImages(
                "NrOfImages should be between 1 and 5. nrOfImages: \(nrOfImages)")
        }

        guard !prompt.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            logger.debug("Invalid prompt", metadata: ["prompt": .string(prompt)])
            throw SwiftBedrockError.invalidPrompt("Prompt is not allowed to be empty.")
        }

        let request: BedrockRequest = try BedrockRequest.createTextToImageRequest(
            model: model, prompt: prompt, nrOfImages: nrOfImages)
        let input: InvokeModelInput = try request.getInvokeModelInput()
        logger.trace(
            "Sending request to invokeModel",
            metadata: [
                "model": .string(model.id), "request": .string(String(describing: input)),
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

        let decoder = JSONDecoder()
        let output: ImageGenerationOutput = try decoder.decode(
            ImageGenerationOutput.self, from: responseBody)

        logger.trace(
            "Generated image(s)",
            metadata: [
                "model": .string(model.id),
                "response": .string(String(describing: response)),
                "images.count": .stringConvertible(output.images.count),
            ])
        return output
    }

    /// Generates 1 to 5 imagevariation(s) from reference images and a text prompt using a specific model.
    /// - Parameters:
    ///   - image: the reference images
    ///   - prompt: the prompt describing the image that should be generated
    ///   - model: the BedrockModel that will be used to generate the image
    ///   - nrOfImages: the number of images that will be generated (must be a number between 1 and 5) optional, default 3
    /// - Throws: SwiftBedrockError.invalidNrOfImages if nrOfImages is not between 1 and 5
    ///           SwiftBedrockError.similarity if similarity is not between 0 and 1
    ///           SwiftBedrockError.invalidPrompt if the prompt is empty
    ///           SwiftBedrockError.invalidResponse if the response body is missing
    /// - Returns: a ImageGenerationOutput object containing an array of generated images
    public func editImage(
        image: String, prompt: String, with model: BedrockModel, similarity: Double? = nil,
        nrOfImages: Int? = nil
    ) async throws -> ImageGenerationOutput {
        logger.trace(
            "Generating image(s) from reference image",
            metadata: [
                "model.id": .string(model.id),
                "model.family": .string(model.family.description),
                "prompt": .string(prompt),
                "nrOfImages": .stringConvertible(nrOfImages ?? "not defined"),
                "similarity": .stringConvertible(similarity ?? "not defined"),
            ])

        let nrOfImages = nrOfImages ?? 1  // FIXME: make 3, stays 1 for now for speed
        guard nrOfImages >= 1 && nrOfImages <= 5 else {
            logger.debug(
                "Invalid nrOfImages", metadata: ["nrOfImages": .stringConvertible(nrOfImages)])
            throw SwiftBedrockError.invalidNrOfImages(
                "NrOfImages should be between 1 and 5. nrOfImages: \(nrOfImages)")
        }

        let similarity = similarity ?? 0.5
        guard similarity >= 0 && similarity <= 1 else {
            logger.debug(
                "Invalid similarity", metadata: ["similarity": .stringConvertible(similarity)])
            throw SwiftBedrockError.invalidNrOfImages(
                "Similarity should be between 0 and 1. similarity: \(similarity)")
        }

        guard !prompt.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            logger.debug("Invalid prompt", metadata: ["prompt": .string(prompt)])
            throw SwiftBedrockError.invalidPrompt("Prompt is not allowed to be empty.")
        }

        let request: BedrockRequest = try BedrockRequest.createImageVariationRequest(
            model: model, prompt: prompt, image: image, similarity: similarity,
            nrOfImages: nrOfImages)
        let input: InvokeModelInput = try request.getInvokeModelInput()
        logger.trace(
            "Sending request to invokeModel",
            metadata: [
                "model": .string(model.id), "request": .string(String(describing: input)),
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

        let decoder = JSONDecoder()
        let output: ImageGenerationOutput = try decoder.decode(
            ImageGenerationOutput.self, from: responseBody)

        logger.trace(
            "Generated image(s)",
            metadata: [
                "model": .string(model.id),
                "response": .string(String(describing: response)),
                "images.count": .stringConvertible(output.images.count),
            ])
        return output
    }
}
