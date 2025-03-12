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

public struct BedrockModel: Equatable, Hashable, Sendable, RawRepresentable {
    public var rawValue: String { id }
    public typealias RawValue = String

    public var id: String
    public let family: ModelFamily
    public let inputModality: [ModelModality]
    public let outputModality: [ModelModality]

    public init(
        id: String, family: ModelFamily, inputModality: [ModelModality] = [.text],
        outputModality: [ModelModality] = [.text]
    ) {
        self.id = id
        self.family = family
        self.inputModality = inputModality
        self.outputModality = outputModality
    }

    public init?(rawValue: String) {
        switch rawValue {
        case BedrockModel.instant.id:
            self = BedrockModel.instant
        case BedrockModel.claudev1.id:
            self = BedrockModel.claudev1
        case BedrockModel.claudev2.id:
            self = BedrockModel.claudev2
        case BedrockModel.claudev2_1.id:
            self = BedrockModel.claudev2_1
        case BedrockModel.claudev3_haiku.id:
            self = BedrockModel.claudev3_haiku
        case BedrockModel.claudev3_5_haiku.id:
            self = BedrockModel.claudev3_5_haiku
        // case BedrockModel.claudev3_5_sonnet_v2.id:
        //     self = BedrockModel.claudev3_5_sonnet_v2
        case BedrockModel.titan_text_g1_premier.id:
            self = BedrockModel.titan_text_g1_premier
        case BedrockModel.titan_text_g1_express.id:
            self = BedrockModel.titan_text_g1_express
        case BedrockModel.titan_text_g1_lite.id:
            self = BedrockModel.titan_text_g1_lite
        case BedrockModel.nova_micro.id:
            self = BedrockModel.nova_micro
        case BedrockModel.titan_image_g1_v2.id:
            self = BedrockModel.titan_image_g1_v2
        case BedrockModel.titan_image_g1_v1.id:
            self = BedrockModel.titan_image_g1_v1
        case BedrockModel.nova_canvas.id:
            self = BedrockModel.nova_canvas
        case BedrockModel.deepseek_r1_v1.id:
            self = BedrockModel.deepseek_r1_v1
        default:
            return nil
        }
    }
}
