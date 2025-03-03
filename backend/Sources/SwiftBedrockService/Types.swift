import Foundation

public struct ModelInfo: Codable {
    let modelName: String
    let providerName: String
    let modelId: String
}

public struct TextCompletion: Codable {
    let completion: String

    public init(_ completion: String) {
        self.completion = completion
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        completion = try container.decode(String.self, forKey: .completion)
    }
}

enum role: String, Codable {
    case user
    case assistant
}
