import Foundation

public enum ModelFamily {
    .
}

// model enum
public struct BedrockModel: RawRepresentable, Equatable, Hashable, Sendable {
    public var rawValue: String
    let family: ModelFamily
    
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
    static let claudev3_5_haiku: BedrockModel = BedrockModel(rawValue: "anthropic.claude-3-5-haiku-20241022-v1:0")
    func isAnthropic() -> Bool {
        switch self {
        case .instant, .claudev1, .claudev2, .claudev2_1, .claudev3_haiku, .claudev3_5_haiku: return true
        default: return false
        }
    }
}

// Amazon Nova
public extension BedrockModel {
    static let nova_micro: BedrockModel = BedrockModel(rawValue: "amazon.nova-micro-v1:0")
    func isNova() -> Bool {
        switch self {
            case .nova_micro: return true
            default: return false
        }
    }
}

// Amazon Titan
public extension BedrockModel {
    static let titan_text_g1_premier: BedrockModel = BedrockModel(rawValue: "amazon.titan-text-premier-v1:0")
    static let titan_text_g1_express: BedrockModel = BedrockModel(rawValue: "amazon.titan-text-express-v1")
    static let titan_text_g1_lite: BedrockModel = BedrockModel(rawValue: "amazon.titan-text-lite-v1")
    func isTitan() -> Bool {
        switch self {
            case .titan_text_g1_premier, .titan_text_g1_express, .titan_text_g1_lite: return true
            default: return false
        }
    }
}

// Meta
public extension BedrockModel {
    static var llama2_13b: BedrockModel { .init(rawValue: "meta.llama2.13b") }
    static var llama2_70b: BedrockModel { .init(rawValue: "meta.llama2.70b") }
    func isMeta() -> Bool {
        switch self {
            case .llama2_13b, .llama2_70b: return true
            default: return false
        }
    }
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