import Foundation

public struct BedrockModel: Equatable, Hashable, Sendable { // FIXME: understand RawRepresentable and put back
    public var rawValue: String
    public let family: ModelFamily

    public init(rawValue: String, family: ModelFamily) {
        self.rawValue = rawValue  // CHECKME: id or rawValue?
        self.family = family
    }

    public init(_ id: String) throws {
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
        default:
            throw SwiftBedrockError.invalidModel(
                "BedrockModel could not be initialized, because the modelId was not recognized")
        }
    }
}

// FIXME: understand this
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
