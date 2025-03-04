import Foundation

enum SwiftBedrockError: Error {
    case invalidMaxTokens(String)
    case invalidTemperature(String)
    case invalidRequest(String)
    case invalidResponse(String)
    case invalidResponseBody(Data?)
    case completionNotFound(String)
    case invalidModel(String)
    case encodingError(String)
    case decodingError(String)
}
