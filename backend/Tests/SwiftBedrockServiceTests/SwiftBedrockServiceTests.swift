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

import Testing
@testable import SwiftBedrockService
@testable import SwiftBedrockTypes

@Suite("SwiftBedrockService Tests")
struct SwiftBedrockServiceTests {
    let bedrock: SwiftBedrock

    init() async throws {
        self.bedrock = try await SwiftBedrock(
            bedrockClient: MockBedrockClient(),
            bedrockRuntimeClient: MockBedrockRuntimeClient()
        )
    }

    @Test("List all models")
    func listModels() async throws {
        let models = try await bedrock.listModels()
        #expect(models.count == 2)
        #expect(models[0].modelId == "anthropic.claude-instant-v1")
        #expect(models[0].modelName == "Claude Instant")
        #expect(models[0].providerName == "Anthropic")
    }

    @Test(
        "Complete text using an implemented model",
        arguments: [
            BedrockModel.nova_micro,
            BedrockModel.titan_text_g1_lite,
            BedrockModel.titan_text_g1_express,
            BedrockModel.titan_text_g1_premier,
            BedrockModel.claudev3_haiku,
            BedrockModel.claudev1,
            BedrockModel.claudev2,
            BedrockModel.claudev2_1,
            BedrockModel.claudev3_haiku,
            BedrockModel.claudev3_5_haiku,
        ])
    func completeTextWithValidModel(model: BedrockModel) async throws {
        let completion: TextCompletion = try await bedrock.completeText(
            "This is a test",
            with: model,
            maxTokens: 100,
            temperature: 0.5
        )
        #expect(completion.completion == "This is the textcompletion for: This is a test")
    }

    @Test(
        "Complete text using an unimplemented model",
        arguments: [
            BedrockModel.llama2_13b,
            BedrockModel.llama2_70b,
        ])
    func completeTextWithInvalidModel(model: BedrockModel) async throws {
        await #expect(throws: SwiftBedrockError.self) {
            let _: TextCompletion = try await bedrock.completeText(
                "This is a test",
                with: model,
                temperature: 0.8)
        }
    }

    @Test("Complete text using a valid temperature", arguments: [0, 0.2, 0.6, 1])
    func completeTextWithValidTemperature(temperature: Double) async throws {
        let completion: TextCompletion = try await bedrock.completeText(
            "This is a test",
            with: BedrockModel.nova_micro,
            temperature: temperature)
        #expect(completion.completion == "This is the textcompletion for: This is a test")
    }

    @Test("Complete text using an invalid temperature", arguments: [-2.5, -1, 1.00001, 2])
    func completeTextWithInvalidTemperature(temperature: Double) async throws {
        await #expect(throws: SwiftBedrockError.self) {
            let _: TextCompletion = try await bedrock.completeText(
                "This is a test",
                with: BedrockModel.nova_micro,
                temperature: temperature)
        }
    }

    @Test(
        "Complete text using a valid maxTokens",
        arguments: [1, 10, 100, 5000])
    func completeTextWithValidMaxTokens(maxTokens: Int) async throws {
        let completion: TextCompletion = try await bedrock.completeText(
            "This is a test",
            with: BedrockModel.nova_micro,
            maxTokens: maxTokens)
        #expect(completion.completion == "This is the textcompletion for: This is a test")
    }

    @Test(
        "Complete text using an invalid maxTokens",
        arguments: [0, -1, -2])
    func completeTextWithInvalidMaxTokens(maxTokens: Int) async throws {
        await #expect(throws: SwiftBedrockError.self) {
            let _: TextCompletion = try await bedrock.completeText(
                "This is a test",
                with: BedrockModel.nova_micro,
                maxTokens: maxTokens)
        }
    }

    @Test(
        "Complete text using a valid prompt",
        arguments: [
            "This is a test", "!@#$%^&*()_+{}|:<>?", String(repeating: "test ", count: 1000),
        ])
    func completeTextWithValidPrompt(prompt: String) async throws {
        let completion: TextCompletion = try await bedrock.completeText(
            prompt,
            with: BedrockModel.nova_micro,
            maxTokens: 200)
        #expect(completion.completion == "This is the textcompletion for: \(prompt)")
    }

    @Test(
        "Complete text using an invalid prompt",
        arguments: ["", " ", " \n  ", "\t"])
    func completeTextWithInvalidPrompt(prompt: String) async throws {
        await #expect(throws: SwiftBedrockError.self) {
            let _: TextCompletion = try await bedrock.completeText(
                prompt,
                with: BedrockModel.nova_micro,
                maxTokens: 10)
        }
    }

    @Test(
        "Complete text using an implemented model",
        arguments: [
            BedrockModel.titan_image_g1_v1,
            BedrockModel.titan_image_g1_v2,
            BedrockModel.nova_canvas,
        ])
    func generateImageWithValidModel(model: BedrockModel) async throws {
        let output: ImageGenerationOutput = try await bedrock.generateImage(
            "This is a text",
            with: model,
            nrOfImages: 3
        )
        #expect(output.images.count == 3)
    }

    @Test(
        "Complete text using an implemented model",
        arguments: [
            BedrockModel.nova_micro,
            BedrockModel.titan_text_g1_lite,
            BedrockModel.titan_text_g1_express,
            BedrockModel.titan_text_g1_premier,
            BedrockModel.claudev3_haiku,
            BedrockModel.claudev1,
            BedrockModel.claudev2,
            BedrockModel.claudev2_1,
            BedrockModel.claudev3_haiku,
            BedrockModel.claudev3_5_haiku,
        ])
    func generateImageWithInvalidModel(model: BedrockModel) async throws {
        await #expect(throws: SwiftBedrockError.self) {
            let _: ImageGenerationOutput = try await bedrock.generateImage(
                "This is a text",
                with: model,
                nrOfImages: 3
            )
        }
    }

    @Test(
        "Complete text using an implemented model",
        arguments: [1, 2, 3, 4, 5])
    func generateImageWithValidNrOfImages(nrOfImages: Int) async throws {
        let output: ImageGenerationOutput = try await bedrock.generateImage(
            "This is a test",
            with: BedrockModel.nova_canvas,
            nrOfImages: nrOfImages
        )
        #expect(output.images.count == nrOfImages)
    }

    @Test(
        "Complete text using an implemented model",
        arguments: [-2, 0, 6, 20])
    func generateImageWithInvalidNrOfImages(nrOfImages: Int) async throws {
        await #expect(throws: SwiftBedrockError.self) {
            let _: ImageGenerationOutput = try await bedrock.generateImage(
                "This is a text",
                with: BedrockModel.nova_canvas,
                nrOfImages: nrOfImages
            )
        }
    }
}
