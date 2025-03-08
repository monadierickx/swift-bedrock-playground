import Foundation

public extension BedrockModel {
    static let titan_text_g1_premier: BedrockModel = BedrockModel(rawValue: "amazon.titan-text-premier-v1:0", family: .titan)
    static let titan_text_g1_express: BedrockModel = BedrockModel(rawValue: "amazon.titan-text-express-v1", family: .titan)
    static let titan_text_g1_lite: BedrockModel = BedrockModel(rawValue: "amazon.titan-text-lite-v1", family: .titan)
}
