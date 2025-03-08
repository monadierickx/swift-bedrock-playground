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
}

// Request context used by application
typealias AppRequestContext = BasicRequestContext

///  Build application
/// - Parameter arguments: application arguments
public func buildApplication(_ arguments: some AppArguments) async throws
    -> some ApplicationProtocol
{
    let environment = Environment()
    let logger = {
        var logger = Logger(label: "HummingbirdBackend")
        logger.logLevel =
            arguments.logLevel ?? environment.get("LOG_LEVEL").flatMap {
                Logger.Level(rawValue: $0)
            } ?? .info
        return logger
    }()
    let router = try await buildRouter()
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
func buildRouter() async throws -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)

    // CORS
    router.add(middleware: CORSMiddleware())

    // Add middleware
    router.addMiddleware {
        // logging middleware
        LogRequestsMiddleware(.trace)
    }
    // Add default endpoint
    router.get("/") { _, _ -> HTTPResponse.Status in
        return .ok
    }

    // Healthcheck
    router.get("/health") { _, _ -> String in
        return "I am healthy!"
    }

    // List models
    // GET /foundation-models lists all models
    router.get("/foundation-models") { request, _ -> [ModelInfo] in
        let bedrock = try await SwiftBedrock()
        return try await bedrock.listModels()
    }

    // POST /foundation-models/text/{modelId}
    router.post("/foundation-models/text/:modelId") { request, context -> TextCompletion in
        do {
            let bedrock = try await SwiftBedrock()
            guard let modelId = context.parameters.get("modelId") else {
                throw HTTPError(.badRequest, message: "Invalid modelId.")
            }
            let model = try BedrockModel(modelId)  // FIXME: some check for the modelId
            let input = try await request.decode(as: TextCompletionInput.self, context: context)
            return try await bedrock.completeText(
                input.prompt,
                with: model,
                maxTokens: input.maxTokens,
                temperature: input.temperature)
        } catch {
            print(error)
            throw error
        }
    }

    return router
}
