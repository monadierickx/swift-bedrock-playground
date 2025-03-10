import Foundation

// text
extension BedrockModel {
    public static let titan_text_g1_premier: BedrockModel = BedrockModel(
        rawValue: "amazon.titan-text-premier-v1:0", family: .titan)
    public static let titan_text_g1_express: BedrockModel = BedrockModel(
        rawValue: "amazon.titan-text-express-v1", family: .titan)
    public static let titan_text_g1_lite: BedrockModel = BedrockModel(
        rawValue: "amazon.titan-text-lite-v1", family: .titan)
}

// image
extension BedrockModel {
    public static let titan_image_g1_v2: BedrockModel = BedrockModel(
        rawValue: "amazon.titan-image-generator-v2:0", family: .titan,
        inputModality: [.text, .image], outputModality: [.image])
    public static let titan_image_g1_v1: BedrockModel = BedrockModel(
        rawValue: "amazon.titan-image-generator-v1", family: .titan,
        inputModality: [.text, .image], outputModality: [.image])
}
