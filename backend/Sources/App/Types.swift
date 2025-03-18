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

import Foundation
import Hummingbird
import SwiftBedrockService
import SwiftBedrockTypes

extension TextCompletion: ResponseCodable {}

struct TextCompletionInput: Codable {
    let prompt: String
    let maxTokens: Int?
    let temperature: Double?
}

struct ChatInput: Codable {
    let prompt: String
    // let history: [BedrockRuntimeClientTypes.Message] = []
}

struct ImageGenerationInput: Codable {
    let prompt: String
    let nrOfImages: Int?
    let stylePreset: String?
    let referenceImage: Data?
    let similarity: Double?

    // static func createImageGenerationInput(
    //     prompt: String,
    //     nrOfImages: Int? = 1,
    //     stylePreset: String? = ""
    // ) throws -> Self {
    //     .init(prompt: prompt, nrOfImages: nrOfImages, stylePreset: stylePreset)
    // }

    // static func createImageVariationInput(
    //     prompt: String,
    //     nrOfImages: Int? = 1,
    //     referenceImage: Data? = nil,
    //     similarity: Double? = nil,
    //     stylePreset: String? = ""
    // ) throws -> Self {
    //     .init(
    //         prompt: prompt,
    //         nrOfImages: nrOfImages,
    //         referenceImage: referenceImage,
    //         similarity: similarity,
    //         stylePreset: stylePreset
    //     )
    // }

    init(
        prompt: String,
        nrOfImages: Int? = 1,
        referenceImage: Data? = nil,
        similarity: Double? = nil,
        stylePreset: String? = ""
    ) {
        self.prompt = prompt
        self.stylePreset = stylePreset
        self.referenceImage = referenceImage
        self.nrOfImages = nrOfImages
        self.similarity = similarity
    }
}

extension ImageGenerationOutput: ResponseCodable {}
