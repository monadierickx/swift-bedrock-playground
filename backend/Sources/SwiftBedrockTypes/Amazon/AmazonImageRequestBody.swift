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

public struct AmazonImageRequestBody: BedrockBodyCodable {
    let taskType: TaskType
    let textToImageParams: TextToImageParams?
    let imageVariationParams: ImageVariationParams?
    let imageGenerationConfig: ImageGenerationConfig

    public static func textToImage(prompt: String, nrOfImages: Int = 3) -> Self {
        return AmazonImageRequestBody(prompt: prompt, nrOfImages: nrOfImages)
    }

    private init(prompt: String, nrOfImages: Int) {
        self.taskType = .textToImage
        self.textToImageParams = TextToImageParams(text: prompt)
        self.imageVariationParams = nil
        self.imageGenerationConfig = ImageGenerationConfig(nrOfImages: nrOfImages)
    }

    public static func imageVariation(
        prompt: String, referenceImage: String, similarity: Double = 0.6, nrOfImages: Int = 3
    ) -> Self {
        return AmazonImageRequestBody(
            prompt: prompt, referenceImage: referenceImage, similarity: similarity,
            nrOfImages: nrOfImages)
    }

    private init(prompt: String, referenceImage: String, similarity: Double, nrOfImages: Int) {
        self.taskType = .imageVariation
        self.textToImageParams = nil
        self.imageVariationParams = ImageVariationParams(
            text: prompt, referenceImage: referenceImage, similarity: similarity)
        self.imageGenerationConfig = ImageGenerationConfig(nrOfImages: nrOfImages)
    }

    public struct TextToImageParams: Codable {
        let text: String
        let conditionImage: String?
        let controlMode: ControlMode?
        let controlStrength: Double?
        let negativeText: String?

        init(text: String) {
            self.text = text
            self.conditionImage = nil
            self.controlMode = nil
            self.controlStrength = nil
            self.negativeText = nil
        }

        init(
            text: String, conditionImage: String, controlMode: ControlMode? = nil,
            controlStrength: Double? = nil, negativeText: String? = nil
        ) {
            self.text = text
            self.conditionImage = conditionImage
            self.controlMode = controlMode
            self.controlStrength = controlStrength
            self.negativeText = negativeText
        }
    }

    public enum ControlMode: String, Codable {
        case cannyEdge = "CANNY_EDGE"
        case segmentation = "SEGMENTATION"
    }

    public struct ImageVariationParams: Codable {
        let text: String
        let images: [String]
        let similarityStrength: Double

        public init(text: String, referenceImage: String, similarity: Double) {
            self.text = text
            self.images = [referenceImage]
            self.similarityStrength = similarity
        }
    }

    public struct ImageGenerationConfig: Codable {
        let cfgScale: Int
        let seed: Int
        let quality: String
        let width: Int
        let height: Int
        let numberOfImages: Int

        public init(nrOfImages: Int = 3) {
            self.cfgScale = 8
            self.seed = 42
            self.quality = "standard"
            self.width = 1024
            self.height = 1024
            self.numberOfImages = nrOfImages
        }
    }
}
