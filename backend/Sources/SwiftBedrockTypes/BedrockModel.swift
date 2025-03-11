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

public struct BedrockModel: Equatable, Hashable, Sendable {  // FIXME: understand RawRepresentable and put back
    public var rawValue: String
    public let family: ModelFamily
    public let inputModality: [ModelModality]
    public let outputModality: [ModelModality]

    public init(
        rawValue: String, family: ModelFamily, inputModality: [ModelModality] = [.text],
        outputModality: [ModelModality] = [.text]
    ) {
        self.rawValue = rawValue  // CHECKME: id or rawValue? Id!! 
        self.family = family
        self.inputModality = inputModality
        self.outputModality = outputModality
    }

    public init?(rawValue id: String) throws {
        switch id {
        case BedrockModel.claudev1.rawValue:
            self = BedrockModel.claudev1 
        case BedrockModel.claudev2.rawValue:
            self.init(rawValue: id, family: .anthropic)
        case BedrockModel.claudev2_1.rawValue:
            self.init(rawValue: id, family: .anthropic)
        case BedrockModel.claudev3_haiku.rawValue:
            self.init(rawValue: id, family: .anthropic)
        case BedrockModel.claudev3_5_haiku.rawValue:
            self.init(rawValue: id, family: .anthropic)
        case BedrockModel.instant.rawValue:
            self.init(rawValue: id, family: .anthropic)
        case BedrockModel.titan_text_g1_premier.rawValue:
            self.init(rawValue: id, family: .titan)
        case BedrockModel.titan_text_g1_express.rawValue:
            self.init(rawValue: id, family: .titan)
        case BedrockModel.titan_text_g1_lite.rawValue:
            self.init(rawValue: id, family: .titan)
        case BedrockModel.nova_micro.rawValue:
            self.init(rawValue: id, family: .nova)

        case BedrockModel.titan_image_g1_v2.rawValue:
            self.init(
                rawValue: id, family: .titan, inputModality: [.text, .image],
                outputModality: [.image])
        case BedrockModel.titan_image_g1_v1.rawValue:
            self.init(
                rawValue: id, family: .titan, inputModality: [.text, .image],
                outputModality: [.image])
        case BedrockModel.nova_canvas.rawValue:
            self.init(
                rawValue: id, family: .nova, inputModality: [.text, .image],
                outputModality: [.image])
        default:
            return nil
        }
    }
}

// FIXME: understand this
// public extension BedrockModel {
//     init?(from: String?) {
//         guard let model = from else {
//             return nil
//         }
//         self.init(rawValue: model)
//         switch self {
//         case .instant,
//              .claudev1,
//              .claudev2,
//              .claudev2_1,
//              .llama2_13b: return
//         default: return nil
//         }
//     }
// }
