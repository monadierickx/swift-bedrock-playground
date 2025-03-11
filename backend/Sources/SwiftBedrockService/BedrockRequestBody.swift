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

@preconcurrency import AWSBedrockRuntime
import Foundation
import SwiftBedrockTypes

struct BedrockRequest {
    let model: BedrockModel
    let contentType: String
    let accept: String
    private let body: BedrockBodyCodable

    private init(
        model: BedrockModel, body: BedrockBodyCodable, contentType: String = "application/json",
        accept: String = "application/json"
    ) {
        self.model = model
        self.body = body
        self.contentType = contentType
        self.accept = accept
    }

    // MARKIT: text
    static func createTextRequest(
        model: BedrockModel, prompt: String, maxTokens: Int = 300, temperature: Double = 0.6
    ) throws -> BedrockRequest {
        try .init(model: model, prompt: prompt, maxTokens: maxTokens, temperature: temperature)
    }

    private init(
        model: BedrockModel, prompt: String, maxTokens: Int, temperature: Double
    ) throws {
        guard model.outputModality.contains(.text) else {
            throw SwiftBedrockError.invalidModel("Modality of \(model.id) is not text")
        }
        var body: BedrockBodyCodable
        switch model.family {
        case .anthropic:
            body = AnthropicRequestBody(
                prompt: prompt, maxTokens: maxTokens, temperature: temperature)
        case .titan:
            body = TitanRequestBody(
                prompt: prompt, maxTokens: maxTokens, temperature: temperature)
        case .nova:
            body = NovaRequestBody(
                prompt: prompt, maxTokens: maxTokens, temperature: temperature)
        default:
            throw SwiftBedrockError.invalidModel(model.id)
        }
        self.init(model: model, body: body)
    }

    // MARKIT: text to image
    public static func createTextToImageRequest(
        model: BedrockModel, prompt: String, nrOfImages: Int
    ) throws -> BedrockRequest {
        try .init(model: model, prompt: prompt, nrOfImages: nrOfImages)
    }

    private init(model: BedrockModel, prompt: String, nrOfImages: Int) throws {
        guard model.inputModality.contains(.text) else {
            throw SwiftBedrockError.invalidModel("Input modality of \(model.id) is not text")
        }
        guard model.outputModality.contains(.image) else {
            throw SwiftBedrockError.invalidModel(
                "Output modality of \(model.id) is not image")
        }
        var body: BedrockBodyCodable
        switch model.family {
        case .titan, .nova:
            body = AmazonImageRequestBody.textToImage(prompt: prompt, nrOfImages: nrOfImages)
        default:
            throw SwiftBedrockError.invalidModel(model.id)
        }
        self.init(model: model, body: body)
    }

    // MARKIT: image variation
    public static func createImageVariationRequest(
        model: BedrockModel, prompt: String, image: String, similarity: Double, nrOfImages: Int
    ) throws -> BedrockRequest {
        try .init(model: model, prompt: prompt, image: image, similarity: similarity, nrOfImages: nrOfImages)
    }

    private init(
        model: BedrockModel, prompt: String, image: String, similarity: Double, nrOfImages: Int
    ) throws {
        guard model.inputModality.contains(.text) else {
            throw SwiftBedrockError.invalidModel("Input modality of \(model.id) is not text")
        }
        guard model.inputModality.contains(.image) else {
            throw SwiftBedrockError.invalidModel("Input modality of \(model.id) is not image")
        }
        guard model.outputModality.contains(.image) else {
            throw SwiftBedrockError.invalidModel(
                "Output modality of \(model.id) is not image")
        }
        var body: BedrockBodyCodable
        switch model.family {
        case .titan, .nova:
            body = AmazonImageRequestBody.imageVariation(
                prompt: prompt, referenceImage: image, similarity: similarity,
                nrOfImages: nrOfImages)
        default:
            throw SwiftBedrockError.invalidModel(model.id)
        }
        self.init(model: model, body: body)
    }

    public func getInvokeModelInput() throws -> InvokeModelInput {
        do {
            let jsonData: Data = try JSONEncoder().encode(self.body)
            return InvokeModelInput(
                accept: self.accept,
                body: jsonData,
                contentType: self.contentType,
                modelId: model.id)
        } catch {
            throw SwiftBedrockError.encodingError(
                "Something went wrong while encoding the request body to JSON for InvokeModelInput: \(error)"
            )
        }
    }

}
