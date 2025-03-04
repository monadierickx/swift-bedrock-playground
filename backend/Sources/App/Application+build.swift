import Hummingbird
import Logging
import SwiftBedrockService

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
    let router = buildRouter()
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
func buildRouter() -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)

    // CORS
    router.add(middleware: CORSMiddleware())

    // Add middleware
    router.addMiddleware {
        // logging middleware
        LogRequestsMiddleware(.info)
    }
    // Add default endpoint
    router.get("/") { _, _ -> HTTPResponse.Status in
        return .ok
    }

    // Healthcheck
    router.get("/health") { _, _ -> String in
        return "I am healthy!"
    }

    let bedrock = SwiftBedrock()
    // List models
    // GET /foundation-models lists all models
    router.get("foundation-models") { request, _ -> [ModelInfo] in
        return try await bedrock.listModels()
    }

    // GET /foundation-models/text/{modelId}
    router.get("foundation-models/text/:modelId") { request, context -> TextCompletion in
        do {
            guard let modelId = context.parameters.get("modelId") else {
                throw HTTPError(.badRequest, message: "Invalid modelId.")  // add modelId
            }
            // check for nil
            let model = BedrockModel(rawValue: modelId)
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
