import Foundation

public struct BedrockModel: Equatable, Hashable, Sendable { // RawRepresentable, 
    public var rawValue: String
    let family: ModelFamily
    
    // public init(rawValue: String) {
    //     self.rawValue = rawValue
    // }

    public init(rawValue: String, family: ModelFamily){
        self.rawValue = rawValue // FIXME: id or rawValue? 
        self.family = family
    }

    public init(_ id: String) {
        self.rawValue = id
        switch id {
            case BedrockModel.claudev1.rawValue: self.family = .anthropic
            case BedrockModel.claudev2.rawValue: self.family = .anthropic
            case BedrockModel.claudev2_1.rawValue: self.family = .anthropic
            case BedrockModel.claudev3_haiku.rawValue: self.family = .anthropic
            case BedrockModel.claudev3_5_haiku.rawValue: self.family = .anthropic
            case BedrockModel.instant.rawValue: self.family = .anthropic
            case BedrockModel.titan_text_g1_premier.rawValue: self.family = .titan
            case BedrockModel.titan_text_g1_express.rawValue: self.family = .titan
            case BedrockModel.titan_text_g1_lite.rawValue: self.family = .titan
            case BedrockModel.nova_micro.rawValue: self.family = .nova
            default: self.family = .unknownModelFamily // FIXME
        }
    }
}

// Anthropic
public extension BedrockModel {
    static let instant: BedrockModel = BedrockModel(rawValue: "anthropic.claude-instant-v1", family: .anthropic)
    static let claudev1: BedrockModel = BedrockModel(rawValue: "anthropic.claude-v1", family: .anthropic)
    static let claudev2: BedrockModel = BedrockModel(rawValue: "anthropic.claude-v2", family: .anthropic)
    static let claudev2_1: BedrockModel = BedrockModel(rawValue: "anthropic.claude-v2:1", family: .anthropic)
    static let claudev3_haiku: BedrockModel = BedrockModel(rawValue: "anthropic.claude-3-haiku-20240307-v1:0", family: .anthropic)
    static let claudev3_5_haiku: BedrockModel = BedrockModel(rawValue: "anthropic.claude-3-5-haiku-20241022-v1:0", family: .anthropic)
    func isAnthropic() -> Bool {
        switch self {
        case .instant, .claudev1, .claudev2, .claudev2_1, .claudev3_haiku, .claudev3_5_haiku: return true
        default: return false
        }
    }
}

// Amazon Nova
public extension BedrockModel {
    static let nova_micro: BedrockModel = BedrockModel(rawValue: "amazon.nova-micro-v1:0", family: .nova)
    func isNova() -> Bool {
        switch self {
            case .nova_micro: return true
            default: return false
        }
    }
}

// Amazon Titan
public extension BedrockModel {
    static let titan_text_g1_premier: BedrockModel = BedrockModel(rawValue: "amazon.titan-text-premier-v1:0", family: .titan)
    static let titan_text_g1_express: BedrockModel = BedrockModel(rawValue: "amazon.titan-text-express-v1", family: .titan)
    static let titan_text_g1_lite: BedrockModel = BedrockModel(rawValue: "amazon.titan-text-lite-v1", family: .titan)
    func isTitan() -> Bool {
        switch self {
            case .titan_text_g1_premier, .titan_text_g1_express, .titan_text_g1_lite: return true
            default: return false
        }
    }
}

// Meta
public extension BedrockModel {
    static var llama2_13b: BedrockModel { .init(rawValue: "meta.llama2.13b", family: .meta) }
    static var llama2_70b: BedrockModel { .init(rawValue: "meta.llama2.70b", family: .meta) }
    func isMeta() -> Bool {
        switch self {
            case .llama2_13b, .llama2_70b: return true
            default: return false
        }
    }
}

// FIXME 
// public extension BedrockModel {
//     init?(from: String?) {
//         guard let model = from else {
//             return nil
//         }
//         self.init(rawValue: model)
//         switch self {
//         case .instant,
//              .claudev1,
//              .claudev2,
//              .claudev2_1,
//              .llama2_13b: return
//         default: return nil
//         }
//     }
// }