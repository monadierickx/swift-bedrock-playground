import Foundation

public extension BedrockModel {
    static var llama2_13b: BedrockModel { .init(rawValue: "meta.llama2.13b", family: .meta) }
    static var llama2_70b: BedrockModel { .init(rawValue: "meta.llama2.70b", family: .meta) }
}
