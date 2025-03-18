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

public struct DeepSeekRequestBody: BedrockBodyCodable {
    let prompt: String
    let temperature: Double
    let top_p: Double
    let max_tokens: Int
    let stop: [String]

    public init(prompt: String, maxTokens: Int, temperature: Double) {
        self.prompt = prompt
        self.temperature = temperature
        self.top_p = 0.9
        self.max_tokens = maxTokens
        self.stop = ["END"]
    }
}
