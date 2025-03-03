import Foundation

// MARK: - Data structures

// model enum
public struct BedrockModel: RawRepresentable, Equatable, Hashable, Sendable {
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

// Anthropic
public extension BedrockModel {
    static let instant: BedrockModel = BedrockModel(rawValue: "anthropic.claude-instant-v1")
    static let claudev1: BedrockModel = BedrockModel(rawValue: "anthropic.claude-v1")
    static let claudev2: BedrockModel = BedrockModel(rawValue: "anthropic.claude-v2")
    static let claudev2_1: BedrockModel = BedrockModel(rawValue: "anthropic.claude-v2:1")
    static let claudev3_haiku: BedrockModel = BedrockModel(rawValue: "anthropic.claude-3-haiku-20240307-v1:0")
    func isAnthropic() -> Bool {
        switch self {
        case .instant, .claudev1, .claudev2, .claudev2_1, .claudev3_haiku: return true
        default: return false
        }
    }
}

// Meta
public extension BedrockModel {
    static var llama2_13b: BedrockModel { .init(rawValue: "meta.llama2.13b") }
    static var llama2_70b: BedrockModel { .init(rawValue: "meta.llama2.70b") }
}

public extension BedrockModel {
    init?(from: String?) {
        guard let model = from else {
            return nil
        }
        self.init(rawValue: model)
        switch self {
        case .instant,
             .claudev1,
             .claudev2,
             .claudev2_1,
             .llama2_13b: return
        default: return nil
        }
    }
}

//public enum BedrockModel: Hashable {
//    case anthropicModel(AnthropicModel)
//    case metaModel(MetaModel)
//    
//    public func id() -> BedrockModelIdentifier {
//        switch self {
//        case .anthropicModel(let anthropic): return anthropic.rawValue
//        case .metaModel(let meta): return meta.rawValue
//        }
//    }
//}

public protocol BedrockResponse: Decodable {
    init(from data: Data) throws
}

public extension BedrockResponse {
    static func decode<T: Decodable>(_ data: Data) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    static func decode<T: Decodable>(json: String) throws -> T {
        let data = json.data(using: .utf8)!
        return try self.decode(data)
    }
}

public protocol BedrockRequest: Encodable {
    func encode() throws -> Data
}

public extension BedrockRequest {
    func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try encoder.encode(self)
    }
}
