import Foundation

public extension BedrockModel {
    static let instant: BedrockModel = BedrockModel(id: "anthropic.claude-instant-v1", family: .anthropic)
    static let claudev1: BedrockModel = BedrockModel(id: "anthropic.claude-v1", family: .anthropic)
    static let claudev2: BedrockModel = BedrockModel(id: "anthropic.claude-v2", family: .anthropic)
    static let claudev2_1: BedrockModel = BedrockModel(id: "anthropic.claude-v2:1", family: .anthropic)
    static let claudev3_haiku: BedrockModel = BedrockModel(id: "anthropic.claude-3-haiku-20240307-v1:0", family: .anthropic)
    static let claudev3_5_haiku: BedrockModel = BedrockModel(id: "anthropic.claude-3-5-haiku-20241022-v1:0", family: .anthropic)
}
