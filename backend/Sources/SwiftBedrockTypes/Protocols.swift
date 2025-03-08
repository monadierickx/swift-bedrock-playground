import Foundation

public protocol BedrockBodyCodable: Codable {}

public protocol ContainsTextCompletion: Codable {
    func getTextCompletion() throws -> TextCompletion
}
