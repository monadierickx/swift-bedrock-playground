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

import Hummingbird
import Logging
import SwiftBedrockService
import SwiftBedrockTypes

/// Application arguments protocol. We use a protocol so we can call
/// `buildApplication` inside Tests as well as in the App executable.
/// Any variables added here also have to be added to `App` in App.swift and
/// `TestArguments` in AppTest.swift
public protocol AppArguments {
    var hostname: String { get }
    var port: Int { get }
    var logLevel: Logger.Level? { get }
    var sso: Bool { get }
}

// Request context used by application
typealias AppRequestContext = BasicRequestContext

///  Build application
/// - Parameter arguments: application arguments
public func buildApplication(
    _ arguments: some AppArguments
) async throws
    -> some ApplicationProtocol
{
    let environment = Environment()
    var logger = Logger(label: "HummingbirdBackend")
    logger.logLevel =
        arguments.logLevel ?? environment.get("LOG_LEVEL").flatMap {
            Logger.Level(rawValue: $0)
        } ?? .info
    let router = try await buildRouter(useSSO: arguments.sso, logger: logger)
    let app = Application(
        router: router,
        configuration: .init(
            address: .hostname(arguments.hostname, port: arguments.port),
            serverName: "HummingbirdBackend"
        ),
        logger: logger
    )
    return app
}

/// Build router
func buildRouter(useSSO: Bool, logger: Logger) async throws -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)

    // CORS
    router.add(middleware: CORSMiddleware())

    // Add middleware
    router.addMiddleware {
        // logging middleware
        LogRequestsMiddleware(.trace)  // FIXME: weird choice mona
    }
    // Add default endpoint
    router.get("/") { _, _ -> HTTPResponse.Status in
        .ok
    }

    // Healthcheck
    router.get("/health") { _, _ -> String in
        "I am healthy!"
    }

    // SwiftBedrock
    let bedrock = try await SwiftBedrock(useSSO: useSSO)

    // List models
    // GET /foundation-models lists all models
    router.get("/foundation-models") { request, _ -> [ModelInfo] in
        try await bedrock.listModels()
    }

    // POST /foundation-models/text/{modelId}
    router.post("/foundation-models/text/:modelId") { request, context -> TextCompletion in
        do {
            guard let modelId = context.parameters.get("modelId") else {
                throw HTTPError(.badRequest, message: "No modelId found.")
            }
            guard let model = BedrockModel(rawValue: modelId) else {
                throw HTTPError(.badRequest, message: "Invalid modelId: \(modelId).")
            }
            guard model.outputModality.contains(.text) else {
                throw HTTPError(.badRequest, message: "Model \(modelId) does not support text output.")
            }
            let input = try await request.decode(as: TextCompletionInput.self, context: context)
            return try await bedrock.completeText(
                input.prompt,
                with: model,
                maxTokens: input.maxTokens,
                temperature: input.temperature
            )
        } catch {
            logger.info(
                "An error occured while generating text",
                metadata: ["url": "/foundation-models/text/:modelId", "error": "\(error)"]
            )
            throw error
        }
    }

    // POST /foundation-models/image/{modelId}
    router.post("/foundation-models/image/:modelId") { request, context -> ImageGenerationOutput in
        do {
            guard let modelId = context.parameters.get("modelId") else {
                throw HTTPError(.badRequest, message: "No modelId found.")
            }
            guard let model = BedrockModel(rawValue: modelId),
                model.outputModality.contains(.image)
            else {
                throw HTTPError(.badRequest, message: "Invalid modelId: \(modelId).")
            }
            let input = try await request.decode(as: ImageGenerationInput.self, context: context)

            var output: ImageGenerationOutput
            if input.referenceImage == nil {
                output = try await bedrock.generateImage(input.prompt, with: model, nrOfImages: input.nrOfImages)
            } else {
                let referenceImage = input.referenceImage!.base64EncodedString()
                output = try await bedrock.editImage(
                    image: referenceImage,
                    prompt: input.prompt,
                    with: model,
                    similarity: input.similarity,
                    nrOfImages: input.nrOfImages
                )
            }
            return output
        } catch {
            logger.info(
                "An error occured while generating image",
                metadata: ["url": "/foundation-models/image/:modelId", "error": "\(error)"]
            )
            throw error
        }
    }

    // POST /foundation-models/chat/{modelId}
    router.post("/foundation-models/chat/:modelId") { request, context -> String in
        do {
            guard let modelId = context.parameters.get("modelId") else {
                throw HTTPError(.badRequest, message: "No modelId found.")
            }
            guard let model = BedrockModel(rawValue: modelId),
                model.inputModality.contains(.text)
            else {
                throw HTTPError(.badRequest, message: "Invalid modelId: \(modelId).")
            }
            let input = try await request.decode(as: ChatInput.self, context: context)
            return try await bedrock.converse(with: model, prompt: input.prompt)
        } catch {
            logger.info(
                "An error occured while generating chat",
                metadata: ["url": "/foundation-models/chat/:modelId", "error": "\(error)"]
            )
            throw error
        }
    }

    return router
}
