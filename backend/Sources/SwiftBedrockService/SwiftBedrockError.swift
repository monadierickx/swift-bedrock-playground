import Foundation

enum BedrockError: Error {
    case invalidMaxTokens(String)
    case invalidTemperature(String)
    case invalidResponse(Data?)
    case invalidModel(String)
}
